using DataFrames: DataFrames as DF
using DuckDB: DB, DBInterface, Stmt, register_data_frame, unregister_data_frame

using .FmtSQL: fmt_join, fmt_read, fmt_select

export create_tbl, set_tbl_col

# default options (for now)
_read_opts = pairs((header = true, skip = 1))

function check_file(source::String)
    # FIXME: handle globs
    isfile(source)
end

function check_tbl(con::DB, source::String)
    df = DBInterface.execute(con, "SHOW TABLES") |> DF.DataFrame
    source in df[!, :name]
end

function fmt_source(con::DB, source::String)
    if check_tbl(con, source)
        return source
    elseif check_file(source)
        return fmt_read(source; _read_opts...)
    else
        throw(NeitherTableNorFileError(con, source))
    end
end

## User facing functions below

# TODO: prepared statements; not used for now
struct Store
    con::DB
    read_csv::Stmt

    function Store(store::String)
        con = DBInterface.connect(DB, store)
        query = fmt_select(fmt_read("(?)"; _read_opts...))
        stmt = DBInterface.prepare(con, query)
        new(con, stmt)
    end
end

Store() = Store(":memory:")
DEFAULT = Store()

"""
    get_tbl_name(source::String, tmp::Bool)

Generate table name from a filename by removing special characters.
If `tmp` is true, then the table name is prefixed by 't_'.

"""
function get_tbl_name(source::String, tmp::Bool)
    name, _ = splitext(basename(source))
    name = replace(name, r"[ ()\[\]{}\\+,.-]+" => "_")
    tmp ? "t_$(name)" : name
end

# TODO: support "CREATE OR REPLACE" & "IF NOT EXISTS" for all create_* functions

function _create_tbl_impl(con::DB, query::String; name::String, tmp::Bool, show::Bool)
    create_table_cmd = "CREATE" * (tmp ? " TEMP" : "") * " TABLE"
    DBInterface.execute(con, "$create_table_cmd $name AS $query")
    return show ? DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $name")) : name
end

"""
    create_tbl(
        con::DB,
        source::String;
        name::String = "",
        tmp::Bool = false,
        show::Bool = false,
        types = Dict(),
    )

Create a table from a file source (CSV, Parquet, line delimited JSON, etc)

The resulting table is saved as the table `name`.  The name of the
created table is returned.

Optionally, if `show` is `true`, the table is returned as a Julia
DataFrame.  This can be useful for interactive debugging in the Julia
REPL.

It is also possible to create the table as a temporary table by
setting the `tmp` flag, i.e. the table is session scoped.  It is
deleted when you close the connection with DuckDB.

When `show` is `false`, and `name` was not provided, a table name is
automatically generated from the basename of the filename.

To enforce data types of a column, you can provide the keyword
argument `types` as a dictionary with column names as keys, and
corresponding DuckDB types as values.

"""
function create_tbl(
    con::DB,
    source::String;
    name::String = "",
    tmp::Bool = false,
    show::Bool = false,
    types = Dict(),
)
    check_file(source) ? true : throw(FileNotFoundError(source))
    if length(name) == 0
        name = get_tbl_name(source, tmp)
    end

    kwargs = Dict{Symbol, String}()
    if length(types) > 0
        kwargs[:types] = "{" * join(("'$key': '$value'" for (key, value) in types), ",") * "}"
    end
    query = fmt_select(fmt_read(source; _read_opts..., kwargs...))

    return _create_tbl_impl(con, query; name, tmp, show)
end

"""
    create_tbl(
        con::DB,
        base_source::String,
        alt_source::String;
        on::Vector{Symbol},
        cols::Vector{Symbol},
        name::String = "",
        fill::Bool = true,
        fill_values::Union{Missing,Dict} = missing,
        tmp::Bool = false,
        show::Bool = false,
    )

Create a table from two sources.  The first is used as the base, and
the second source is used as a source for alternative values by doing
a `LEFT JOIN`, i.e. all rows in the base source are retained.

Either sources can be a table in DuckDB, or a file source as in the
single source variant.

The resulting table is saved as the table `name`.  The name of the
created table is returned.  The behaviour for `tmp`, and `show` are
identical to the single source variant.

The `LEFT JOIN` is performend on the columns specified by `on`.  The
set of columns picked from the alternative source after the join are
specified by `cols`.

If the alternate source has a subset of rows, the default behaviour is
to back-fill the corresponding values from the base table.  If this is
not desired, then `fill` can be set to `false`.  In that case they
will be `missing` values.

To fill an alternate value, you can set `fill_values` to a dictionary, where
the keys are column names, and the values are the corresponding fill
value.  If any columns are missing, it falls back to back-fill.

TODO: In the future an "error" option would also be supported, to fail
loudly when the number of rows do not match between the base and
alternative source.

"""
function create_tbl(
    con::DB,
    base_source::String,
    alt_source::String;
    on::Vector{Symbol},
    cols::Vector{Symbol},
    name::String = "",
    fill::Bool = true,
    fill_values::Union{Missing, Dict} = missing,
    tmp::Bool = false,
    show::Bool = false,
)
    if (check_file(alt_source) && length(name) == 0)
        name = get_tbl_name(alt_source, tmp)
    end

    sources = [fmt_source(con, src) for src in (base_source, alt_source)]
    query = fmt_join(sources...; on = on, cols = cols, fill = fill, fill_values = fill_values)

    return _create_tbl_impl(con, query; name, tmp, show)
end

function _get_index(con::DB, source::String, on::Symbol)
    # TODO: for file source instead of reading again, save to a tmp table
    source = fmt_source(con, source)
    base = DBInterface.execute(con, "SELECT $on FROM $source") |> DF.DataFrame
    return getproperty(base, on)
end

function _set_tbl_col_impl(
    con::DB,
    source::String,
    idx::Vector,
    vals::Vector;
    on::Symbol,
    col::Symbol,
    opts...,
)
    df = DF.DataFrame([idx, vals], [on, col])
    tmp_tbl = "t_col_$(col)"
    register_data_frame(con, df, tmp_tbl)
    # FIXME: should be fill=error (currently not implemented)
    res = create_tbl(con, source, tmp_tbl; on = [on], cols = [col], fill = false, opts...)
    unregister_data_frame(con, tmp_tbl)
    return res
end

"""
    set_tbl_col(
        con::DB,
        source::String,
        cols::Dict{Symbol,Vector{T}};
        on::Symbol,
        name::String,
        tmp::Bool = false,
        show::Bool = false,
    ) where T <: Union{Int64, Float64, String, Bool}

Create a table from a source (either a DuckDB table or a file), where
columns can be set to vectors provided in a dictionary `cols`.  The
keys are the new column names, and the vector values are the column
entries.  This transform is very similar to `create_tbl`, except that
the alternate source is a data structure in Julia.

The resulting table is saved as the table `name`.  The name of the
created table is returned.

All other options behave as the two source version of `create_tbl`.

"""
function set_tbl_col(
    con::DB,
    source::String,
    cols::Dict{Symbol, Vector{T}};
    on::Symbol,
    name::String,
    tmp::Bool = false,
    show::Bool = false,
) where {T <: Union{Int64, Float64, String, Bool}}
    # TODO: is it worth it to have the ability to set multiple
    # columns?  If such a feature is required, we can use
    # cols::Dict{Symbol, Vector{Any}}, and get the cols and vals
    # as: keys(cols), and values(cols)
    if (check_file(source) && length(name) == 0)
        name = get_tbl_name(source, tmp)
    end

    # for now, support only one column
    if length(cols) > 1
        throw(DomainError(keys(cols), "only single column is support"))
    end

    idx = _get_index(con, source, on)
    vals = first(values(cols))
    if length(idx) != length(vals)
        msg = "Length of index column and values are different\n"
        _cols = [idx, vals]
        data =
            [get.(_cols, i, "-") for i in 1:maximum(length, _cols)] |>
            Iterators.flatten |>
            collect |>
            x -> reshape(x, 2, :) |> permutedims
        msg *= pretty_table(String, data; header = ["index", "value"])
        throw(DimensionMismatch(msg))
    end
    _set_tbl_col_impl(
        con,
        source,
        idx,
        vals;
        on = on,
        col = first(keys(cols)),
        name = name,
        tmp = tmp,
        show = show,
    )
end

"""
    set_tbl_col(
        con::DB,
        source::String,
        cols::Dict{Symbol, T};
        on::Symbol,
        name::String = "",
        where_::String = "",
        tmp::Bool = false,
        show::Bool = false,
    ) where T

Create a table from a source (either a DuckDB table or a file), where
a column can be set to the values provided by the dictionary `cols`.
The keys are the column names, whereas the values are the column
entries.  Note that in this case, all entries in a column are set to
the same value.  Unlike the vector variant of this function, all
values of the column are set to this value.

All other options and behaviour are same as the vector variant of this
function.

"""
function set_tbl_col(
    con::DB,
    source::String,
    cols::Dict{Symbol, T};
    on::Symbol,
    name::String = "",
    where_::String = "",
    tmp::Bool = false,
    show::Bool = false,
) where {T}
    if (check_file(source) && length(name) == 0)
        name = get_tbl_name(source, tmp)
    end

    source = fmt_source(con, source)
    subquery = fmt_select(source; cols...)
    if length(where_) > 0
        subquery *= " WHERE $(where_)"
    end

    query = fmt_join(source, "($subquery)"; on = [on], cols = [keys(cols)...], fill = true)
    return _create_tbl_impl(con, query; name = name, tmp = tmp, show = show)
end

function set_tbl_col(
    con::DB,
    source::String;
    on::Symbol,
    col::Symbol,
    name::String,
    apply::Function,
    tmp::Bool = false,
    show::Bool = false,
) end

function select(
    con::DB,
    source::String,
    expression::String;
    name::String = "",
    tmp::Bool = false,
    show::Bool = false,
)
    src = fmt_source(con, source)
    query = "SELECT * FROM $src WHERE $expression"

    if (check_file(source) && length(name) == 0)
        name = get_tbl_name(source, tmp)
    end

    return _create_tbl_impl(con, query; name = name, tmp = tmp, show = show)
end

# TODO:
# - filter rows (where clause)
#   - is filtering on columns needed?

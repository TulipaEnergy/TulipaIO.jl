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
        query = fmt_select("(?)"; header = true, skip = 1)
        stmt = DBInterface.prepare(con, query)
        new(con, stmt)
    end
end

Store() = Store(":memory:")
DEFAULT = Store()

function tmp_tbl_name(source::String)
    name, _ = splitext(basename(source))
    name = replace(name, r"[ ()\[\]{}\\+,.-]+" => "_")
    "t_$(name)"
end

# TODO: support "CREATE OR REPLACE" & "IF NOT EXISTS" for all create_* functions

function _create_tbl_impl(con::DB, query::String; name::String, tmp::Bool, show::Bool)
    if length(name) > 0
        DBInterface.execute(con, "CREATE $(tmp ? "TEMP" : "") TABLE $name AS $query")
        return show ? DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $name")) : name
    else # only show
        res = DBInterface.execute(con, query)
        return DF.DataFrame(res)
    end
end

"""
    create_tbl(
        con::DB,
        source::String;
        name::String = "",
        tmp::Bool = false,
        show::Bool = false,
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

When `show` is `false`, and `name` was not provided, a table name
autotomatically generated from the basename of the filename is used.
This also unconditionally sets the temporary table flag to `true`.

"""
function create_tbl(
    con::DB,
    source::String;
    name::String = "",
    tmp::Bool = false,
    show::Bool = false,
)
    check_file(source) ? true : throw(FileNotFoundError(source))
    query = fmt_select(source; _read_opts...)

    if (length(name) == 0) && !show
        tmp = true
        name = tmp_tbl_name(source)
    end

    return _create_tbl_impl(con, query; name = name, tmp = tmp, show = show)
end

"""
    create_tbl(
        con::DB,
        base_source::String,
        alt_source::String;
        on::Vector{String},
        cols::Vector{String},
        variant::String = "",
        fill::Union{Bool,Vector::Any} = true,
        tmp::Bool = false,
        show::Bool = false,
    )

Create a table from two sources.  The first is used as the base, and
the second source is used as a source for alternative values by doing
a `LEFT JOIN`, i.e. all rows in the base source are retained.

Either sources can be a table in DuckDB, or a file source as in the
single source variant.

The resulting table is saved as the table `variant`.  The name of the
created table is returned.  The behaviour for `tmp`, and `show` are
identical to the single source variant.

The `LEFT JOIN` is performend on the columns specified by `on`.  The
set of columns picked from the alternative source after the join are
specified by `cols`.

If the alternate source has a subset of rows, the default behaviour is
to back-fill the corresponding values from the base table.  If this is
not desired, then `fill` can be set to `false`.  In that case they
will be `missing` values.

It is also possible to set the fill value to a specific value, however
then you have to specify a value for every column that is included
from the alternative source.  (TODO: remove this restriction)

TODO: In the future an "error" option would also be supported, to fail
loudly when the number of rows do not match between the base and
alternative source.

"""
function create_tbl(
    con::DB,
    base_source::String,
    alt_source::String;
    on::Vector{String},
    cols::Vector{String},
    variant::String = "",
    fill::Union{Bool,Vector::Any} = true,
    tmp::Bool = false,
    show::Bool = false,
)
    sources = [fmt_source(con, src) for src in (base_source, alt_source)]
    query = fmt_join(sources...; on = on, cols = cols, fill = fill)

    if (length(variant) == 0) && !show
        tmp = true
        variant = tmp_tbl_name(alt_source)
    end

    return _create_tbl_impl(con, query; name = variant, tmp = tmp, show = show)
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
    res = create_tbl(
        con,
        source,
        tmp_tbl;
        on = [String(on)],
        cols = [String(col)],
        fill = false,
        opts...,
    )
    unregister_data_frame(con, tmp_tbl)
    return res
end

"""
    set_tbl_col(
        con::DB,
        source::String,
        vals::Vector;
        on::Symbol,
        col::Symbol,
        variant::String = "",
        tmp::Bool = false,
        show::Bool = false,
    )

Create a table from a source (either a DuckDB table or a file), where
a column can be set to the vector provided by `vals`.  This transform
is very similar to `create_tbl`, except that the alternate source is a
data structure in Julia.

The resulting table is saved as the table `name`.  The name of the
created table is returned.

All other options behave as the two source version of `create_tbl`.

"""
function set_tbl_col(
    con::DB,
    source::String,
    vals::Vector;
    on::Symbol,
    col::Symbol,
    variant::String = "",
    tmp::Bool = false,
    show::Bool = false,
)
    # TODO: is it worth it to have the ability to set multiple
    # columns?  If such a feature is required, we can use
    # cols::Dict{Symbol, Vector{Any}}, and get the cols and vals
    # as: keys(cols), and values(cols)
    idx = _get_index(con, source, on)
    if length(idx) != length(vals)
        msg = "Length of index column and values are different\n"
        cols = [idx, vals]
        data =
            [get.(cols, i, "-") for i = 1:maximum(length, cols)] |>
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
        col = col,
        variant = variant,
        tmp = tmp,
        show = show,
    )
end

function set_tbl_col(
    con::DB,
    source::String,
    value;
    on::Symbol,
    col::Symbol,
    variant::String = "",
    tmp::Bool = false,
    show::Bool = false,
)
    idx = _get_index(con, source, on)
    vals = fill(value, length(idx))
    _set_tbl_col_impl(
        con,
        source,
        idx,
        vals;
        on = on,
        col = col,
        variant = variant,
        tmp = tmp,
        show = show,
    )
end

# FIXME: signature clashes w/ above
# function set_tbl_col(
#     con::DB,
#     source::String,
#     value::Number;
#     on::Symbol,
#     col::Symbol,
#     scale::Bool = true,
#     variant::String = "",
#     tmp::Bool = false,
#     show::Bool = false,
# ) end

function set_tbl_col(
    con::DB,
    source::String;
    on::Symbol,
    col::Symbol,
    apply::Function,
    variant::String = "",
    tmp::Bool = false,
    show::Bool = false,
) end

# TODO:
# - filter rows (where clause)
#   - apply on reduced set
#   - apply on reduced set, and update original
#   - is filtering on columns needed?

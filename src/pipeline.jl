using DataFrames: DataFrames as DF
using DuckDB: DB, DBInterface, Stmt, register_data_frame, unregister_data_frame
using Glob: glob

using .FmtSQL: fmt_join, fmt_read, fmt_select

export create_tbl, as_table, select_tbl, rename_cols, update_tbl, tbl_cols

# default options for reading
_read_opts = pairs((header = true,))

to_posix(path::String) = replace(path, "\\" => "/")

function check_file(source::String)
    # NOTE: Check if `pwd()` and `source` are on the same drive
    # (relevant only on Windows), if they are not on the same drive,
    # skip call to `relpath` since it returns a path without the drive
    # letter, breaking the path.  `same_root` will always be true on
    # *nix since all filesystems are mounted under "/".
    same_root = mapreduce(splitdrive, ((d1, p1), (d2, p2)) -> d1 == d2, [source, pwd()])

    # NOTE: `to_posix` is necessary since `glob` accepts only POSIX
    # paths regardless of platform
    nfiles = (same_root ? source |> relpath : source) |> to_posix |> glob |> length
    nfiles > 0
end

function check_tbl(con::DB, source::String)
    df = DBInterface.execute(con, "SHOW TABLES") |> DF.DataFrame
    source in df[!, :name]
end

function fmt_source(con::DB, source::String; opts...)
    if check_tbl(con, source)
        return source
    elseif check_file(source)
        return fmt_read(source; _read_opts..., opts...)
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

function _create_tbl_impl(
    con::DB,
    query::String;
    name::String,
    tmp::Bool,
    show::Bool,
    replace_if_exists::Bool = true,
)
    create_table_cmd =
        "CREATE" * (replace_if_exists ? " OR REPLACE" : "") * (tmp ? " TEMP" : "") * " TABLE"
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
        replace_if_exists = true,
        opts...
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

If `replace_if_exists` is `true`, then the `CREATE OR REPLACE` is used instead
of just `CREATE`, allowing DuckDB to replace the table, if a table with the
same name already exists.

To enforce data types of a column, you can provide the keyword
argument `types` as a dictionary with column names as keys, and
corresponding DuckDB types as values.

Any remaining keyword arguments are passed on to the `read_*` table
functions of DuckDB.  Any options here will override options provided
earlier, e.g. you can override the default `header=true` option set by
`TulipaIO`.

TODO: add option to select while creating table

"""
function create_tbl(
    con::DB,
    source::String;
    name::String = "",
    tmp::Bool = false,
    show::Bool = false,
    types = Dict(),
    replace_if_exists = true,
    opts...,
)
    check_file(source) ? true : throw(FileNotFoundError(source))
    if length(name) == 0
        name = get_tbl_name(source, tmp)
    end

    kwargs = Dict{Symbol, String}()
    if length(types) > 0
        kwargs[:types] = "{" * join(("'$key': '$value'" for (key, value) in types), ",") * "}"
    end
    query = fmt_select(fmt_read(source; _read_opts..., kwargs..., opts...))

    return _create_tbl_impl(con, query; name, tmp, show, replace_if_exists)
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
        opts...
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

Any remaining keyword arguments are passed on to the `read_*` table
functions of DuckDB.  Any options here will override options provided
earlier, e.g. you can override the default `header=true` option set by
`TulipaIO`.

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
    replace_if_exists = true,
    opts...,
)
    if check_file(alt_source) && length(name) == 0
        name = get_tbl_name(alt_source, tmp)
    end

    sources = [fmt_source(con, src; opts...) for src in (base_source, alt_source)]
    query = fmt_join(sources...; on = on, cols = cols, fill = fill, fill_values = fill_values)

    return _create_tbl_impl(con, query; name, tmp, show, replace_if_exists)
end

function _get_index(con::DB, source::String, on::Symbol)
    # TODO: for file source instead of reading again, save to a tmp table
    source = fmt_source(con, source)
    base = DBInterface.execute(con, "SELECT $on FROM $source") |> DF.DataFrame
    return getproperty(base, on)
end

"""
    as_table(op::Function, con::DB, name::String, args...)

Temporarily "import" a Julia object into a DuckDB session.  It does it
by first creating a `DataFrame`.  `args...` are passed on to the
`DataFrame` constructor as is.  It is registered with the DuckDB
connection `con` as the table `name`.  This function can be used with
a `do`-block like this:

```jldoctest
using DuckDB: DBInterface, DB, query
using DataFrames: DataFrame

con = DBInterface.connect(DB)

as_table(con, "mytbl", (;col=collect(1:5))) do con, name
    query(con, "SELECT col, col+2 as 'shift_2' FROM '\$name'")
end |> DataFrame

# output

5×2 DataFrame
 Row │ col    shift_2
     │ Int64  Int64
─────┼────────────────
   1 │     1        3
   2 │     2        4
   3 │     3        5
   4 │     4        6
   5 │     5        7
```

"""
function as_table(op::Function, con::DB, name::String, args...)
    df = DF.DataFrame(args...)
    register_data_frame(con, df, name)
    try
        op(con, name)
    finally
        unregister_data_frame(con, name)
    end
end

"""
    create_tbl(
        con::DB,
        source::String,
        cols::Dict{K, Vector{V}};
        on::Symbol,
        name::String,
        tmp::Bool = false,
        show::Bool = false,
        opts...
    ) where {K <: Union{String, Symbol}, V <: Union{Bool, Real, String, Any, Nothing}}

Create a table from a source (either a DuckDB table or a file), where
columns can be set to vectors provided in a dictionary `cols`.  The
keys are the new column names, and the vector values are the column
entries.  This transform is very similar to `create_tbl`, except that
the alternate source is a data structure in Julia.

The resulting table is saved as the table `name`.  The name of the
created table is returned.

All other options behave as the two source version of `create_tbl`,
including additional keyword arguments.

"""
function create_tbl(
    con::DB,
    source::String,
    cols::Dict{K, Vector{V}};
    on::Symbol,
    name::String,
    tmp::Bool = false,
    show::Bool = false,
    opts...,
) where {K <: Union{String, Symbol}, V <: Union{Bool, Real, String, Any, Nothing}}
    # TODO: is it worth it to have the ability to set multiple
    # columns?  If such a feature is required, we can use
    # cols::Dict{Symbol, Vector{Any}}, and get the cols and vals
    # as: keys(cols), and values(cols)
    if check_file(source) && length(name) == 0
        name = get_tbl_name(source, tmp)
    end

    # for now, support only one column
    if length(cols) > 1
        throw(DomainError(keys(cols), "only single column is support"))
    end

    idx = _get_index(con, source, on)
    if !all(length(idx) .== map(length, values(cols)))
        msg = "Length of index column and values are different\n"
        _cols = [idx, values(cols)...]
        data =
            [get.(_cols, i, "-") for i in 1:maximum(length, _cols)] |>
            Iterators.flatten |>
            collect |>
            x -> reshape(x, 2, :) |> permutedims
        msg *= pretty_table(String, data; header = ["index", "value"])
        throw(DimensionMismatch(msg))
    end
    col_names = keys(cols) |> collect
    as_table(con, "t_$(join(col_names, '_'))", merge(cols, Dict(on => idx))) do con, tname
        create_tbl(
            con,
            source,
            tname;
            on = [on],
            cols = col_names,
            fill = false,
            name,
            tmp,
            show,
            opts...,
        )
    end
end

"""
    create_tbl(
        con::DB,
        source::String,
        cols::Dict{K, V};
        on::Symbol,
        name::String = "",
        where_::String = "",
        tmp::Bool = false,
        show::Bool = false,
        opts...
    ) where {K <: Union{String, Symbol}, V <: Union{Bool, Real, String, Any, Nothing}}

Create a table from a source (either a DuckDB table or a file), where
a column can be set to the values provided by the dictionary `cols`.
The keys are the column names, whereas the values are the column
entries.  Note that in this case, all entries in a column are set to
the same value.  Unlike the vector variant of this function, all
values of the column are set to this value.

All other options and behaviour are same as the vector variant of this
function, including additional keyword arguments.

"""
function create_tbl(
    con::DB,
    source::String,
    cols::Dict{K, V};
    on::Symbol,
    name::String = "",
    where_::String = "",
    tmp::Bool = false,
    show::Bool = false,
    replace_if_exists = true,
    opts...,
) where {K <: Union{String, Symbol}, V <: Union{Bool, Real, String, Any, Nothing}}
    if check_file(source) && length(name) == 0
        name = get_tbl_name(source, tmp)
    end

    source = fmt_source(con, source; opts...)
    subquery = fmt_select(source; cols...)
    if length(where_) > 0
        subquery *= " WHERE $(where_)"
    end

    query = fmt_join(source, "($subquery)"; on = [on], cols = [keys(cols)...], fill = true)
    return _create_tbl_impl(con, query; name, tmp, show, replace_if_exists)
end

# function create_tbl(
#     con::DB,
#     source::String;
#     on::Symbol,
#     col::Symbol,
#     name::String,
#     apply::Function,
#     tmp::Bool = false,
#     show::Bool = false,
# ) end

"""
    select_tbl(con::DB, source::String, where_::String; opts...)

Select a subset of rows from a source (table or file) by passing an
SQL where clause as `where_`.

All keyword arguments are passed to the `read_*` function if the
source is a file, ignored otherwise.

"""
function select_tbl(con::DB, source::String; where_::String = "", opts...)
    src = fmt_source(con, source; opts...)
    where_ = (where_ == "" ? "" : "WHERE $where_")
    query = "SELECT * FROM $src $where_"
    return DBInterface.execute(con, query) |> DF.DataFrame
end

# TODO:
# - is filtering on columns needed?

"""
    rename_cols(con::DB, tblname::String; col_remap...)

Rename the columns of a table.  The old to new column name mapping is
passed as keyword arguments.

"""
function rename_cols(con::DB, tbl::String; col_remap...)
    check_tbl(con, tbl) ? true : throw(TableNotFoundError(con, tbl))

    for (old, new) in col_remap
        DBInterface.execute(con, "ALTER TABLE $(tbl) RENAME COLUMN $(old) to $(new);")
    end
end

"""
    update_tbl(
        con::DB,
        tbl::String,
        cols::Dict{K, V};
        where_::String ="",
        show = false
    ) where {K <: Union{String, Symbol}, V <: Union{Bool, Real, String, Any, Nothing}}

Update the values of a column in an existing table
"""
function update_tbl(
    con::DB,
    tbl::String,
    cols::Dict{K, V};
    where_::String = "",
    show = false,
) where {K <: Union{String, Symbol}, V <: Union{Bool, Real, String, Any, Nothing}}
    check_tbl(con, tbl) ? true : throw(TableNotFoundError(con, tbl))

    expressions = join(("$key = '$value'" for (key, value) in cols), ",")
    where_ = (where_ == "" ? "" : "WHERE $where_")
    DBInterface.execute(con, "UPDATE $tbl SET $expressions $where_")

    if show
        return DBInterface.execute(con, "SELECT * FROM $tbl") |> DF.DataFrame
    end
end

"""
    tbl_cols(con::DB, tbl::String)

Return all the column names for the given table as a DataFrame.

Example:
```jldoctest
using DuckDB, TulipaIO
con = DBInterface.connect(DuckDB.DB)
DBInterface.execute(con, "CREATE TABLE mytbl AS SELECT range AS a, range+2 AS b FROM range(3)")
TulipaIO.tbl_cols(con, "mytbl")

# output

2×1 DataFrame
 Row │ column_name
     │ String
─────┼─────────────
   1 │ a
   2 │ b
```

"""
function tbl_cols(con::DB, tbl::String)
    # other columns: data_type, column_default
    query = "select column_name from information_schema.columns where table_name='$tbl'"
    return DBInterface.execute(con, query) |> DF.DataFrame
end

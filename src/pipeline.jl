using DataFrames: DataFrames as DF
using DuckDB: DB, DBInterface, Stmt

using .FmtSQL: fmt_join, fmt_read, fmt_select

export create_tbl

# default options (for now)
_read_opts = pairs((header = true, skip = 1))

function check_file(source::String)
    # FIXME: handle globs
    isfile(source)
end

function check_tbl(con::DB, source::String)
    tbls = DBInterface.execute(con, "SHOW TABLES").tbl[:name]
    source in tbls
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
    name, _ = replace(splitext(basename(source)), r"[ ()\[\]{}\\+,.]+" => "_")
    "t_$(name)"
end

# TODO: support "CREATE OR REPLACE" & "IF NOT EXISTS" for all create_* functions

function _create_tbl_impl(con::DB, query::String; name::String, tmp::Bool, show::Bool)
    if (length(name) == 0) && !show
        tmp = true
        name = tmp_tbl_name(source)
    end

    if length(name) > 0
        DBInterface.execute(con, "CREATE $(tmp ? "TEMP" : "") TABLE $name AS $query")
        return show ? DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $name")) : name
    else # only show
        res = DBInterface.execute(con, query)
        return DF.DataFrame(res)
    end
end

function create_tbl(
    con::DB,
    source::String;
    name::String = "",
    tmp::Bool = false,
    show::Bool = false,
)
    check_file(source) ? true : throw(FileNotFoundError(source))
    query = fmt_select(source; _read_opts...)

    return _create_tbl_impl(con, query; name = name, tmp = tmp, show = show)
end

function create_tbl(
    con::DB,
    base_source::String,
    alt_source::String;
    variant::String = "",
    on::Vector{String},
    cols::Vector{String},
    fill::Union{Bool,Vector::Any} = true,
    tmp::Bool = false,
    show::Bool = false,
)
    sources = [fmt_source(con, src) for src in (base_source, alt_source)]
    query = fmt_join(sources...; on = on, cols = cols, fill = fill)

    return _create_tbl_impl(con, query; name = variant, tmp = tmp, show = show)
end

end

# TODO:
# - filter rows (where clause)
# - dataframe as data source

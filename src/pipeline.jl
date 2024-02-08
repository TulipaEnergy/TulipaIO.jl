module pipeline

import DataFrames as DF
import DuckDB: DB, DBInterface, Stmt

import Printf: format, Format

function sprintf(fmt::String, args...)
    format(Format(fmt), args...)
end

function fmt_opts(source::String; opts...)
    _src = '?' in source ? "$source" : "'$(source)'"
    join(["$(_src)"; [join(p, "=") for p in opts]], ", ")
end

function reader(source::String)
    _, ext = splitext(source)
    if ext in (".csv", ".parquet", ".json")
        return "read_$(ext[2:end])_auto"
    elseif '?' in source
        # FIXME: how to support other file formats?
        return "read_csv_auto"
    else
        error("$(ext[2:end]): unsupported input file '$(source)'")
    end
end

function fmt_query(source::String; opts...)
    sprintf("SELECT * FROM %s(%s)", reader(source), fmt_opts(source; opts...))
end

function fmt_join(
    subquery1::String,
    subquery2::String;
    on::Vector{String},
    cols::Vector{String},
)
    exclude = join(cols, ", ")
    include = join(map(c -> "t2.$c", cols), ", ")
    select_ = "SELECT t1.* EXCLUDE ($exclude), $include"

    join_on = join(map(c -> "t1.$c = t2.$c", on), " AND ")
    from_ = "FROM $subquery1 t1 LEFT JOIN $subquery2 t2 ON ($join_on)"

    "$(select_)\n$(from_)"
end

function check_file(source::String)
    # FIXME: handle globs
    isfile(source) || throw(ArgumentError("$(source): is not a regular file"))
    source
end

struct Store
    con::DB
    read_csv::Stmt

    function Store(store::String)
        con = DBInterface.connect(DB, store)
        query = fmt_query("(?)"; header = true, skip = 1)
        stmt = DBInterface.prepare(con, query)
        new(con, stmt)
    end
end

Store() = Store(":memory:")

function read_csv(con::DB, source::String)
    check_file(source)
    query = fmt_query("(?)"; header = true, skip = 1)
    res = DBInterface.execute(con, query, [source])
    return DF.DataFrame(res)
end

function read_csv_alt_cols(
    con::DB,
    source1::String,
    source2::String;
    on::Vector{String},
    cols::Vector{String},
)
    check_file(source1)
    check_file(source2)
    subquery = sprintf("read_csv_auto(%s)", fmt_opts("(?)"; header = true, skip = 1))
    query = fmt_join(subquery, subquery, on = on, cols = cols)
    res = DBInterface.execute(con, query, [source1, source2])
    return DF.DataFrame(res)
end

function tmp_tbl_name(source::String)
    name, _ = replace(splitext(basename(source)), r"[ ()\[\]{}\\+,.]+" => "_")
    "t_$(name)"
end

function create_tbl(con::DB, name::String, source::String; tmp::Bool = false)
    check_file(source)
    query = fmt_query(source; header = true, skip = 1)
    TEMP = tmp ? "TEMP" : ""
    DBInterface.execute(con, "CREATE $TEMP TABLE $name AS $query")
end

function create_alt_tbl(
    con::DB,
    ref::String,
    alt::String,
    source::String;
    on::Vector{String},
    cols::Vector{String},
    tmp::Bool = false,
)
    check_file(source)
    TEMP = tmp ? "TEMP" : ""
    # TODO: support "CREATE OR REPLACE" & "IF NOT EXISTS"
    create_ = "CREATE $TEMP TABLE $alt AS"

    subquery = sprintf("%s(%s)", reader(source), fmt_opts(source; header = true, skip = 1))
    query = fmt_join(ref, subquery; on = on, cols = cols)

    DBInterface.execute(con, "$(create_)\n$(query)")
end


# TODO:
# - filter rows (where clause)
# - dataframe as data source

end

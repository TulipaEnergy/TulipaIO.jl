using DataFrames: DataFrames as DF
using DuckDB: DB, DBInterface, Stmt
using Printf: format, Format

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

function fmt_select(source::String; opts...)
    sprintf("SELECT * FROM %s(%s)", reader(source), fmt_opts(source; opts...))
end

function fmt_join(
    from_subquery::String,
    join_subquery::String;
    on::Vector{String},
    cols::Vector{String},
    fill::Union{Bool,Vector::Any},
)
    exclude = join(cols, ", ")
    if fill       # back fill
        # e.g.: IFNULL(t2.investable, t1.investable) AS investable
        include = join(map(c -> "IFNULL(t2.$c, t1.$c) AS $c", cols), ", ")
    else if !fill # explicit missing
        include = join(map(c -> "t2.$c", cols), ", ")
    else          # fill with default
        if length(fill) != length(cols)
            msg = "number of default values does not match columns\n"
            msg = msg * "columns: $cols\n"
            msg = msg * "defaults: $fill"
            error(msg)
        end
        include = join(map((c, f) -> "IFNULL(t2.$c, $f) AS $c", zip(cols, fill)), ", ")
    end
    select_ = "SELECT t1.* EXCLUDE ($exclude), $include"

    join_on = join(map(c -> "t1.$c = t2.$c", on), " AND ")
    from_ = "FROM $from_subquery t1 LEFT JOIN $join_subquery t2 ON ($join_on)"

    "$(select_)\n$(from_)"
end

# TODO: check_file -> check_source: file, file glob, table name
function check_file(source::String)
    # FIXME: handle globs
    isfile(source) || throw(ArgumentError("$(source): is not a regular file"))
    source
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

function read_file(con::DB, source::String)
    check_file(source)
    query = fmt_select(source; header = true, skip = 1) # FIXME: don't hardcode options
    res = DBInterface.execute(con, query)
    return DF.DataFrame(res)
end

function read_file_replace_cols(
    con::DB,
    source1::String,
    source2::String;
    on::Vector{String},
    cols::Vector{String},
    fill::Union{Bool,Vector::Any} = true,
)
    check_file(source1)
    check_file(source2)
    sources = [ # FIXME: don't hardcode options
        sprintf("%s(%s)", reader(src), fmt_opts(src; header = true, skip = 1)) for
        src in (source1, source2)
    ]
    query = fmt_join(sources...; on = on, cols = cols, fill = fill)
    res = DBInterface.execute(con, query)
    return DF.DataFrame(res)
end

function tmp_tbl_name(source::String)
    name, _ = replace(splitext(basename(source)), r"[ ()\[\]{}\\+,.]+" => "_")
    "t_$(name)"
end

function create_tbl(con::DB, source::String; name::String = "", tmp::Bool = false)
    check_file(source)
    query = fmt_select(source; header = true, skip = 1) # FIXME: don't hardcode options
    if length(name) == 0
        tmp = true
        name = tmp_tbl_name(source)
    end
    DBInterface.execute(con, "CREATE $(tmp ? "TEMP" : "") TABLE $name AS $query")
    return name
end

function create_tbl_variant(
    con::DB,
    base_source::String,
    alt_source::String;
    variant::String = "",
    on::Vector{String},
    cols::Vector{String},
    fill::Union{Bool,Vector::Any} = true,
    tmp::Bool = false,
)
    check_file(alt_source)
    if length(variant) == 0
        tmp = true
        variant = tmp_tbl_name(alt_source)
    end
    # TODO: support "CREATE OR REPLACE" & "IF NOT EXISTS"
    create_ = "CREATE $(tmp ? "TEMP" : "") TABLE $variant AS"

    # FIXME: don't hardcode options
    subquery = sprintf("%s(%s)", reader(alt_source), fmt_opts(alt_source; header = true, skip = 1))
    query = fmt_join(base_source, subquery; on = on, cols = cols, fill = fill)

    DBInterface.execute(con, "$(create_)\n$(query)")
    variant
end

end

# TODO:
# - filter rows (where clause)
# - dataframe as data source

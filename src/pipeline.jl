using DataFrames: DataFrames as DF
using DuckDB: DB, DBInterface, Stmt, register_data_frame, unregister_data_frame

using .FmtSQL: fmt_join, fmt_read, fmt_select

export create_tbl

# default options (for now)
_read_opts = pairs((header = true, skip = 1))

function check_file(source::String)
    # FIXME: handle globs
    isfile(source)
end

function check_tbl(con::DB, source::String)
    res = DBInterface.execute(con, "SHOW TABLES")
    @show res
    tbls = res.tbl[:name]
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

    if (length(variant) == 0) && !show
        tmp = true
        variant = tmp_tbl_name(alt_source)
    end

    return _create_tbl_impl(con, query; name = variant, tmp = tmp, show = show)
end

function _get_index(con::DB, source::String, idx_col::Symbol)
    # TODO: for file source instead of reading again, save to a tmp table
    source = fmt_source(con, source)
    res = DBInterface.execute(con, "SELECT $idx_col FROM $source")
    @show res
    base = DF.DataFrame(res)
    return getproperty(base, idx_col)
end

function _set_tbl_col_impl(
    con::DB,
    source::String,
    idx::Vector,
    idx_col::Symbol,
    set_col::Symbol,
    vals::Vector;
    opts...,
)
    df = DF.DataFrame([idx, vals], [idx_col, set_col])
    tmp_tbl = "t_col_$(set_col)"
    register_data_frame(con, df, tmp_tbl)
    # FIXME: should be fill=error (currently not implemented)
    res = create_tbl(
        con,
        source,
        tmp_tbl;
        on = [String(idx_col)],
        cols = [String(set_col)],
        fill = false,
        opts...,
    )
    unregister_data_frame(con, tmp_tbl)
    return res
end

function set_tbl_col(
    con::DB,
    source::String,
    idx_col::Symbol,
    set_col::Symbol,
    vals::Vector;
    variant::String = "",
    tmp::Bool = false,
    show::Bool = false,
)
    # TODO: is it worth it to have the ability to set multiple
    # columns?  If such a feature is required, we can use
    # set_cols::Dict{Symbol, Vector{Any}}, and get the cols and vals
    # as: keys(set_cols), and values(set_cols)
    idx = _get_index(con, source, idx_col)
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
        idx_col,
        set_col,
        vals;
        variant = variant,
        tmp = tmp,
        show = show,
    )
end

function set_tbl_col(
    con::DB,
    source::String,
    idx_col::Symbol,
    set_col::Symbol,
    value;
    variant::String = "",
    tmp::Bool = false,
    show::Bool = false,
)
    idx = _get_index(con, source, idx_col)
    vals = fill(value, length(idx))
    _set_tbl_col_impl(
        con,
        source,
        idx,
        idx_col,
        set_col,
        vals;
        variant = variant,
        tmp = tmp,
        show = show,
    )
end

# FIXME: signature clashes w/ above
# function set_tbl_col(
#     con::DB,
#     source::String,
#     idx_col::Symbol,
#     set_col::Symbol,
#     value::Number;
#     scale::Bool,
#     variant::String = "",
#     tmp::Bool = false,
#     show::Bool = false,
# ) end

function set_tbl_col(
    con::DB,
    source::String,
    idx_col::Symbol,
    set_col::Symbol,
    apply::Function;
    variant::String = "",
    tmp::Bool = false,
    show::Bool = false,
) end

# TODO:
# - filter rows (where clause)
#   - apply on reduced set
#   - apply on reduced set, and update original
#   - is filtering on columns needed?

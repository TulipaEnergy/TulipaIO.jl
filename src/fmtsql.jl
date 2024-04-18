module FmtSQL

using Printf: format, Format

sprintf(fmt::String, args...) = format(Format(fmt), args...)

# quote literals appropriately for SQL
fmt_quote(item) = "$(item)"
fmt_quote(item::Union{AbstractString,AbstractChar}) = "'$(item)'"

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

function fmt_read(source::String; opts...)
    sprintf("%s(%s)", reader(source), fmt_opts(source; opts...))
end

function fmt_select(source::String; opts...)
    sprintf("SELECT * FROM %s", fmt_read(source; opts...))
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
    elseif !fill # explicit missing
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

end # module FmtSQL

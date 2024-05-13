module FmtSQL

include("exceptions.jl")

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

function fmt_select(source::String; cols...)
    alts = if length(cols) > 0
        exclude = join(keys(cols), ", ")
        include = join([sprintf("%s AS %s", fmt_quote(p[2]), p[1]) for p in cols], ", ")
        "EXCLUDE ($exclude), $include"
    else
        ""
    end
    "SELECT * $alts FROM $source"
end

function fmt_join(
    from_subquery::String,
    join_subquery::String;
    on::Vector{Symbol},
    cols::Vector{Symbol},
    fill::Bool,
    fill_values::Union{Missing,Dict} = missing,
)
    exclude = join(cols, ", ")
    if fill
        # e.g.: IFNULL(t2.investable, t1.investable) AS investable
        if ismissing(fill_values)
            include = join(map(c -> "IFNULL(t2.$c, t1.$c) AS $c", cols), ", ")
        else
            include = join(
                map(c -> begin
                        default = get(fill_values, c, missing)
                        fill_value = ismissing(default) ? "t1.$c" : fmt_quote(default)
                        "IFNULL(t2.$c, $fill_value) AS $c"
                    end, cols),
                ", ",
            )
        end
    else
        include = join(map(c -> "t2.$c", cols), ", ")
    end
    select_ = "SELECT t1.* EXCLUDE ($exclude), $include"

    join_on = join(map(c -> "t1.$c = t2.$c", on), " AND ")
    from_ = "FROM $from_subquery t1 LEFT JOIN $join_subquery t2 ON ($join_on)"

    "$(select_)\n$(from_)"
end

_ops = (:(==), :(>), :(:<), :(>=), :(<=), :(!=), :%, :in)
_ops_map = (; :(!=) => "<>", :% => "LIKE", :in => "IN")

macro where_(exprs...)
    xs = []
    for e in exprs
        if !isa(e, Expr) || e.head != :call || length(e.args) != 3
            throw(InvalidWhereCondition(e))
        end
        op, lhs, rhs = e.args
        if !(op in _ops)
            # FIXME: more specific exception
            throw(InvalidWhereCondition(e))
        end
        op = op in keys(_ops_map) ? _ops_map[op] : "$op"
        if op == "IN"
            rhs = eval(rhs)     # FIXME: eval in invocation environment
            if isa(rhs, AbstractRange)
                op = "BETWEEN"
                rhs = sprintf("%s AND %s", fmt_quote(rhs.start), fmt_quote(rhs.stop))
            elseif length(rhs) > 1
                rhs = sprintf("(%s)", join([sprintf(fmt_quote(rhs[1]), i) for i in rhs], ", "))
            else
                # FIXME: clearer exception
                throw(TypeError("$(rhs): not a range or array type"))
            end
        else
            rhs = fmt_quote(rhs)
        end
        append!(xs, [sprintf("(%s %s %s)", lhs, op, rhs)])
    end
    join(xs, " AND ")
end

end # module FmtSQL

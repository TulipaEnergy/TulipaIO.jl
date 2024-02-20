import Base: merge

import JSON3
import PrettyTables: pretty_table

export read_esdl_json

# ESDL parsing utilities
"""
    reduce_unless(fn, itr; init, sentinel)

A version of `reduce` that stops if reduction returns `sentinel` at any point

  - `fn`: reduction function
  - `itr`: iterator to reduce
  - `init`: initial value (unlike standard, mandatory)
  - `sentinel`: stop if reduction returns `sentinel`

Returns reduced value, or `sentinel`

"""
function reduce_unless(fn, itr; init, sentinel)
    res = init
    for i in itr
        res = fn(res, i)
        if res == sentinel
            return sentinel
        end
    end
    return res
end

"""
    resolve!(field, values, errs)

Given a set of `values`, ensure they are either all equal or
`nothing`.  On failure, push `field` to `errs`.

  - `field`: the field to push in `errs` to signal failure
  - `values`: values to check
  - `errs`: vector of field names with errors

Returns resolved value

"""
function resolve!(field, values, errs)
    nonull = Iterators.filter(i -> i != nothing, values) |> collect
    num = length(nonull)
    if num == 0
        return nothing
    elseif num > 1
        # check equality when more than one non-null values
        iseq = reduce_unless(
            (r, i) -> r ? isequal(i...) : false,      # proceed iff equal
            [nonull[i:i+1] for i = 1:num if i < num]; # paired iteration
            init = true,
            sentinel = false,
        )
        !iseq && push!(errs, field)
    end
    return nonull[1] # unused on error, return for type-stability
end

"""
    merge(args...)

Given a set of structs, merge them and return a single struct.  Fields
are merged when they are equal or `nothing`.  Anything else raises an
error with a summary of the fields with conflicting values.

"""
function merge(args...; names = [])
    nargs = length(args)
    if nargs == 1
        return args[1]
    end

    tp = typeof(args[1])
    errs = []
    res = tp((resolve!(f, map(t -> getfield(t, f), args), errs) for f in fieldnames(tp))...)

    if length(errs) > 0
        msg = "Following fields have conflicting values:\n"
        # filter fields with errors for all arguments
        data = map(t -> map(f -> getfield(t, f), errs), args) |> collect |> x -> hcat(errs, x...)
        hdr = ["fields", ((length(names) == 0) ? (1:length(args)) : names)...]
        msg *= pretty_table(String, data; header = hdr)
        error(msg)
    end
    res
end

# JSON parsing utility
"""
    json_get(json, reference; trunc = 0)

Given a JSON document, find the object pointed to by the reference
(e.g. "//@<key>.<array_idx>/@<key>"); truncate the last `trunc`
components of the reference.

"""
function json_get(json, reference::String; trunc::Int = 0)
    function to_idx(token)
        v = split(token, ".")
        # JSON is 0-indexed, Julia is 1-indexed
        length(v) > 1 ? [Symbol(v[1]), 1 + parse(Int, v[2])] : [Symbol(v[1])]
    end
    # NOTE: index 2:end because there is a leading '/'
    idx = collect(Iterators.flatten(map(to_idx, split(reference, "/@"))))[2:(end-trunc)]
    reduce(getindex, idx; init = json) # since $ref is from JSON, assume valid
end

# FIXME: ideally idcs should be typed Vector{Union{Int64,Symbol}}
function json_get(json, idcs; default::Any = nothing)
    reduce_unless((ret, i) -> get(ret, i, default), idcs; init = json, sentinel = default)
end

# ESDL class parsers
function cost_info(asset)
    basepath = [:costInformation, :investmentCosts]
    cost = json_get(asset, [:costInformation]; default = nothing)
    if cost == nothing
        return (nothing, nothing, nothing, nothing)
    end

    ret = []
    for cost_type in (:investmentCosts, :variableOperationalAndMaintenanceCosts)
        !in(cost_type, keys(cost)) && continue
        val = json_get(cost, [cost_type, :value]; default = nothing)
        unit = Dict(
            k => json_get(asset, [basepath..., :profileQuantityAndUnit, k]; default = nothing)
            for k in (:unit, :perMultiplier, :perUnit)
        )
        push!(ret, val, "$(unit[:unit])/$(unit[:perMultiplier])$(unit[:perUnit])")
    end
    ret
end

# struct to hold parsed data
struct Asset
    initial_capacity::Union{Float64,Nothing}
    lifetime::Union{Float64,Nothing}
    initial_storage_level::Union{Float64,Nothing}
    investment_cost::Union{Float64,Nothing}
    investment_cost_unit::Union{String,Nothing}
    variable_cost::Union{Float64,Nothing}
    variable_cost_unit::Union{String,Nothing}
end

# constructor to call different parsers to determine the fields
function Asset(asset::JSON3.Object)
    Asset(
        get(asset, :power, nothing),             # initial_capacity
        get(asset, :technicalLifetime, nothing), # lifetime
        get(asset, :fillLevel, nothing),         # initial_storage_level
        cost_info(asset)...,                     # *_cost{,_unit}
    )
end

# entry point for the parser
"""
    read_esdl_json(json_path)

This is the entry point for the parser.  It reads the ESDL JSON file
at `json_path` and returns an array of from/to node names, along with
a struct of Asset type.  The Asset attribute values are determined by
combining the attribute values of the from & to ESDL assets nodes.  If
the two nodes have conflicting asset values, an error is raised:

    [(from_name, to_name, Asset(...)), (..., ..., ...), ...]

"""
function read_esdl_json(json_path)
    json = JSON3.read(open(f -> read(f, String), json_path))
    flow_from_json(json)
end

"""
    flow_from_json(json)

Returns an array of from/to node names from a JSON document (as parsed
by JSON3.jl):

    [(from_name, to_name, Asset(...)), (..., ..., ...), ...]

"""
function flow_from_json(json)
    """
        edge(from_asset, to_asset)

    Given a pair of assets, extract all the asset attributes and
    construct an edge.

    """
    function edge(from_asset, to_asset)
        names = [from_asset[:name], to_asset[:name]]
        merged_asset = merge(Asset(from_asset), Asset(to_asset); names = names)
        (names..., merged_asset)
    end

    """
        edges(asset)

    Given an asset, find all this_asset -> other_asset edges

    """
    function edges(asset)
        [
            edge(asset, json_get(json, to_port[Symbol("\$ref")]; trunc = 2)) for
            port in asset[:port] if occursin("OutPort", port[:eClass]) for
            to_port in port[:connectedTo]
        ]
    end

    flows = []
    flow_from_json_impl!(json, flows; find_edge = edges)
    flows
end

"""
    flow_from_json_impl!(json, flows; find_edge)

Find all flows (from/to node names) from a JSON document.

  - `json`: JSON document
  - `flows`: The flows are returned by appending to this vector
  - `find_edge`: Function invoked as `find_edge(asset::JSON3.Object)` to find the flows
    originating from an asset

"""
function flow_from_json_impl!(json::JSON3.Object, flows; find_edge)
    if :asset in keys(json)
        flow_edges = [find_edge(asset) for asset in json[:asset] if :name in keys(asset)]
        append!(flows, flow_edges...)
    end

    if :area in keys(json)
        flow_from_json_impl!(json[:area], flows; find_edge = find_edge)
    end

    if :instance in keys(json)
        flow_from_json_impl!(json[:instance], flows; find_edge = find_edge)
    end
end

function flow_from_json_impl!(json::JSON3.Array{JSON3.Object}, flows; find_edge)
    for json_el in json
        flow_from_json_impl!(json_el, flows; find_edge = find_edge)
    end
end

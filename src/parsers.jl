import JSON3

export read_esdl_json

"""
    read_esdl_json(json_path)

Reads the ESDL JSON file at `json_path` and returns an array of
from/to node names:

    [(from_name, to_name), (..., ...), ...]
"""
function read_esdl_json(json_path)
    json = JSON3.read(open(f -> read(f, String), json_path))
    flow_from_json(json)
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

struct Asset
    initial_capacity::Float64
    lifetime::Float64
    investment_cost::Float64
    investment_cost_unit::String
    variable_cost::Float64
    variable_cost_unit::String
end

function Asset(asset::JSON3.Object)
    Asset(get(asset, :power, nothing), get(asset, :technicalLifetime, nothing), cost_info(asset)...)
end

"""
    flow_from_json(json)

Returns an array of from/to node names from a JSON document (as parsed
by JSON3.jl):

    [(from_name, to_name), (..., ...), ...]
"""
function flow_from_json(json)
    """
        edges(asset)

    Given an asset, find all this_asset -> other_asset edges

    """
    function edges(asset)
        # TODO: return type: Vector{Tuple{String, String, <struct>}};
        # we can do this only after we have an ESDL example with a
        # complete set of Tulipa attributes
        [
            (
                asset[:name],
                json_get(json, to_port[Symbol("\$ref")]; trunc = 2)[:name],
                Asset(asset),
            ) for port in asset[:port] if occursin("OutPort", port[:eClass]) for
            to_port in port[:connectedTo]
        ]
    end

    flows = []
    flow_from_json_impl!(json, flows; find_edge = edges)
    flows
end

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
    reduce(getindex, idx; init = json)
end

function json_get(json, idcs::Vector{Symbol}; default::Any = nothing)
    reduce_unless((ret, i) -> get(ret, i, default), idcs; init = json, sentinel = default)
end

function json_get(json, idcs::Vector{Int}; default::Any = nothing)
    reduce_unless((ret, i) -> get(ret, i, default), idcs; init = json, sentinel = default)
end

function json_get(json, idcs::Vector{Union{Int,Symbol}}; default::Any = nothing)
    reduce_unless((ret, i) -> get(ret, i, default), idcs; init = json, sentinel = default)
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

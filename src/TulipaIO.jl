module TulipaIO

include("exceptions.jl")

# ESDL JSON parser
include("parsers.jl")

# DuckDB pipeline
include("fmtsql.jl")
include("pipeline.jl")

end

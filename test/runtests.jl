using TulipaIO: TulipaIO
using Test: Test, @test, @testset, @test_throws

const DATA = joinpath(@__DIR__, "data")

# Run all files in test folder starting with `test-` and ending with `.jl`
test_files = filter(file -> startswith("test-")(file) && endswith(".jl")(file), readdir(@__DIR__))
for file in test_files
    include(file)
end

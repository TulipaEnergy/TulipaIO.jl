using JSON3: JSON3

@testset "Parsing utilities" begin
    @testset "reduce_unless" begin
        _sum = (i, j) -> nothing in (i, j) ? nothing : i + j
        res = TulipaIO.reduce_unless(_sum, 1:3; init = 0, sentinel = nothing)
        @test res == sum(1:3)
        res = TulipaIO.reduce_unless(_sum, [1:3..., nothing]; init = 0, sentinel = nothing)
        @test res == nothing
    end

    @testset "resolve!" begin
        errs = []
        TulipaIO.resolve!(:fail, [ones(Int, 3)..., nothing], errs)
        @test length(errs) == 0
        TulipaIO.resolve!(:fail, [ones(Int, 3)..., 2, nothing], errs)
        @test :fail in errs
        TulipaIO.resolve!("fail", [ones(Int, 3)..., 2, nothing], errs)
        @test "fail" in errs
    end

    @testset "merge" begin
        struct Data
            foo::Union{Int, Nothing}
            bar::Union{Bool, Nothing}
            baz::Union{String, Nothing}
        end
        d0 = Data(nothing, nothing, nothing)
        d1 = Data(42, true, "answer")
        d2 = Data(42, true, nothing)
        d3 = Data(42, false, "not answer")
        d4 = Data(99, false, "not answer")

        # nothing is overridden by a value
        res = merge(d0, d1)
        @test res == d1
        res = merge(d1, d2)
        @test res == d1
        @test_throws ErrorException merge(d1, d3) # error when conflicting values
        if (VERSION.major >= 1) && (VERSION.minor >= 8)
            # error message lists fields w/ conflicting values
            @test_throws r"bar.+\n.+baz" merge(d1, d2, d3)
            @test_throws r"foo.+\n.+bar.+\n.+baz" merge(d1, d2, d4)
            # error message column names
            @test_throws r"fields.+1.+2" merge(d2, d4) # default: sequence
            @test_throws r"fields.+bla.+dibla" merge(d2, d4; names = ["bla", "dibla"])
        end
    end
end

@testset "Follow references in JSON" begin
    json_path = joinpath(DATA, "esdl/norse-mythology.json")
    json = JSON3.read(open(f -> read(f, String), json_path))
    @testset "String references" begin
        target = TulipaIO.json_get(json, "//@instance.0/@area/@area.1/@asset.1/@port.1")
        @test "ca13a453-57d1-4a63-b933-ca63fe33af34" == target[:id]
        target = TulipaIO.json_get(json, "//@instance.0/@area/@area.1/@asset.1/@port.1"; trunc = 2)
        @test "GasNetwork_6912" == target[:name]
    end

    @testset "Key/index references" begin
        # NOTE: "//@instance.0/@area/@area.1/@area.0/@asset.4", indices are 1-indexed in Julia
        target = TulipaIO.json_get(json, [:instance, 1, :area, :area, 2, :area, 1, :asset, 5])
        @test "PumpedHydroPower_eabf" == target[:name]
        @test :costInformation in keys(target)
    end
end

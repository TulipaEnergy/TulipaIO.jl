import JSON3

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

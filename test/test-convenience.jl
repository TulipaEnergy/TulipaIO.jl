using CSV, DataFrames, DuckDB, TulipaIO

@testset "Test convenience functions" begin
    @testset "Read CSV folder" begin
        tmpdir = mktempdir()
        CSV.write(
            joinpath(tmpdir, "some-file.csv"),
            DataFrame(:a => ["A", "B", "C"], :x => rand(3)),
        )
        open(joinpath(tmpdir, "ignore-this-file.txt"), "w") do io
            println(io, "Nothing")
        end

        connection = DBInterface.connect(DuckDB.DB)
        read_csv_folder(connection, tmpdir)
        @test (DBInterface.execute(connection, "SHOW TABLES") |> DataFrame |> df -> df.name) ==
              ["some_file"]
    end
end

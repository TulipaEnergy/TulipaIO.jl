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

    @testset "Test show_tables and get_table" begin
        connection = DBInterface.connect(DuckDB.DB)
        create_tbl(connection, "data/Norse/assets-data.csv"; name = "my_table")
        @test show_tables(connection).name == ["my_table"]
        @test "Asgard_Battery" in get_table(connection, "my_table").name
    end
end

using CSV: CSV
using DataFrames: DataFrames, DataFrame
using DuckDB: DuckDB, DBInterface
using TulipaIO: TulipaIO

@testset "Test convenience functions" begin
    @testset "Read CSV folder" begin
        tmpdir = mktempdir()
        csv_file = joinpath(tmpdir, "some-file.csv")
        CSV.write(csv_file, DataFrame(:a => ["A", "B", "C"], :x => rand(3)))

        open(joinpath(tmpdir, "ignore-this-file.txt"), "w") do io
            println(io, "Nothing")
        end

        connection = DBInterface.connect(DuckDB.DB)
        TulipaIO.read_csv_folder(connection, tmpdir)
        @test TulipaIO.check_tbl(connection, "some_file")
    end

    @testset "Test reading w/ schema" begin
        con = DBInterface.connect(DuckDB.DB)
        schemas = Dict(
            "rep_periods_mapping" =>
                Dict(:period => "INT", :rep_period => "VARCHAR", :weight => "DOUBLE"),
        )
        TulipaIO.read_csv_folder(con, "data/Norse"; schemas)
        df_types = DuckDB.query(con, "DESCRIBE rep_periods_mapping") |> DataFrame
        @test df_types.column_name == ["period", "rep_period", "weight"]
        @test df_types.column_type == ["INTEGER", "VARCHAR", "DOUBLE"]
    end

    @testset "Test show_tables and get_table" begin
        connection = DBInterface.connect(DuckDB.DB)
        TulipaIO.create_tbl(connection, "data/Norse/assets-data.csv"; name = "my_table")
        @test TulipaIO.show_tables(connection).name == ["my_table"]
        @test "Asgard_Battery" in TulipaIO.get_table(connection, "my_table").name
    end
end

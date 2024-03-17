import CSV
import DataFrames as DF
import DuckDB: DB, DBInterface

TIO = TulipaIO

function shape(df::DF.DataFrame)
    return (DF.nrow(df), DF.ncol(df))
end

@testset "Utilities" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")

    # redundant for the current implementation, needed when we support globs
    @test TIO.check_file(csv_path)
    @test !TIO.check_file("not-there")

    con = DBInterface.connect(DB)
    tbl_name = "mytbl"

    @testset "Check if table exists" begin
        DBInterface.execute(con, "CREATE TABLE $tbl_name AS SELECT * FROM range(5)")
        @test TIO.check_tbl(con, tbl_name)
        @test !TIO.check_tbl(con, "not_there")
    end

    @testset "Conditionally format source as SQL" begin
        read_ = TIO.fmt_source(con, csv_path)
        @test occursin("read_csv", read_)
        @test occursin(csv_path, read_)
        @test TIO.fmt_source(con, tbl_name) == tbl_name
        @test_throws TIO.NeitherTableNorFileError TIO.fmt_source(con, "not-there")
        msg_re = r"not-there.+"
        msg_re *= "$con"
        @test_throws msg_re TIO.fmt_source(con, "not-there")
    end
end

@testset "Read CSV" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")
    csv_copy = replace(csv_path, "data.csv" => "data-copy.csv")

    df_org = DF.DataFrame(CSV.File(csv_path; header = 2))

    con = DBInterface.connect(DB)

    @testset "CSV -> DataFrame" begin
        df_res = TIO.create_tbl(con, csv_path; show = true)
        @test shape(df_org) == shape(df_res)
        @test_throws TIO.FileNotFoundError TIO.create_tbl(con, "not-there")
        @test_throws r"not-there" TIO.create_tbl(con, "not-there")
    end

    @testset "CSV w/ alternatives -> DataFrame" begin
        df_res = TIO.create_tbl(
            con,
            csv_path,
            csv_copy;
            on = ["name"],
            cols = ["investable"],
            show = true,
        )
        df_exp = DF.DataFrame(CSV.File(csv_copy; header = 2))
        @test df_exp.investable == df_res.investable
        @test df_org.investable != df_res.investable
    end

    @testset "CSV -> table" begin
        tbl_name = TIO.create_tbl(con, csv_path; name = "no_assets")
        df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
        @test shape(df_org) == shape(df_res)
    end

    @testset "table + CSV w/ alternatives -> table" begin
        tbl_name = TIO.create_tbl(
            con,
            "no_assets",
            csv_copy;
            variant = "alt_assets",
            on = ["name"],
            cols = ["investable"],
        )
        df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
        df_exp = DF.DataFrame(CSV.File(csv_copy; header = 2))
        @test df_exp.investable == df_res.investable
        @test df_org.investable != df_res.investable
    end
end

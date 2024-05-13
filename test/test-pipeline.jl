import CSV
import DataFrames as DF
import DuckDB: DB, DBInterface

TIO = TulipaIO

function shape(df::DF.DataFrame)
    return (DF.nrow(df), DF.ncol(df))
end

function tmp_tbls(con::DB)
    res = DBInterface.execute(con, "SELECT name FROM (SHOW ALL TABLES) WHERE temporary = true")
    return DF.DataFrame(res)
end

"""
        join_cmp(df1, df2, cols; on::Union{Symbol, Vector{Symbol}})

When row order is different, do a join to determine equality; use the
columns `cols`, join on `on` (often :name).  The resulting DataFrame
is returned.  It uniquifies columns with clashing names (see
`?DF.leftjoin`), and stores a "source" under the `:source` column.

"""
function join_cmp(df1, df2, cols; on::Union{Symbol,Vector{Symbol}})
    DF.leftjoin(df1[!, cols], df2[!, cols]; on = on, makeunique = true, source = :source)
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
        if (VERSION.major >= 1) && (VERSION.minor >= 8)
            msg_re = r"not-there.+"
            msg_re *= "$con"
            @test_throws msg_re TIO.fmt_source(con, "not-there")
        end
    end
end

@testset "Read CSV" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")
    csv_copy = replace(csv_path, "data.csv" => "data-copy.csv")
    csv_fill = replace(csv_path, "data.csv" => "data-alt.csv")

    df_org = DF.DataFrame(CSV.File(csv_path; header = 2))

    con = DBInterface.connect(DB)

    @testset "CSV -> DataFrame" begin
        df_res = TIO.create_tbl(con, csv_path; show = true)
        @test shape(df_org) == shape(df_res)
        @test_throws TIO.FileNotFoundError TIO.create_tbl(con, "not-there")
        if (VERSION.major >= 1) && (VERSION.minor >= 8)
            @test_throws r"not-there" TIO.create_tbl(con, "not-there")
        end
    end

    @testset "CSV w/ alternatives -> DataFrame" begin
        opts = Dict(:on => [:name], :cols => [:investable], :show => true)
        df_res = TIO.create_tbl(con, csv_path, csv_copy; opts..., fill = false)
        df_exp = DF.DataFrame(CSV.File(csv_copy; header = 2))
        @test df_exp.investable == df_res.investable
        @test df_org.investable != df_res.investable

        @testset "no filling for missing rows" begin
            df_res = TIO.create_tbl(con, csv_path, csv_fill; opts..., fill = false)
            df_ref = DF.DataFrame(CSV.File(csv_fill; header = 2))
            # NOTE: row order is different, join to determine equality
            cmp = join_cmp(df_res, df_ref, ["name", "investable"]; on = :name)
            @test subset(cmp, :investable_1 => ismissing).source .== "left_only" |> all
            @test subset(cmp, :investable_1 => !ismissing).source .== "both" |> all
        end

        @testset "back-filling missing rows" begin
            df_res = TIO.create_tbl(con, csv_path, csv_fill; opts..., fill = true)
            df_exp = DF.DataFrame(CSV.File(csv_copy; header = 2))
            cmp = join_cmp(df_exp, df_res, ["name", "investable"]; on = :name)
            @test all(cmp.investable .== cmp.investable_1)
            @test cmp.source .== "both" |> all
        end

        @testset "back-filling missing rows w/ alternate values" begin
            df_res = TIO.create_tbl(
                con,
                csv_path,
                csv_fill;
                opts...,
                fill = true,
                fill_values = Dict(:investable => true),
            )
            df_ref = DF.DataFrame(CSV.File(csv_fill; header = 2))
            cmp = join_cmp(df_res, df_ref, ["name", "investable"]; on = :name)
            @test subset(cmp, :investable_1 => ismissing).investable |> all
        end
    end

    @testset "CSV -> table" begin
        tbl_name = TIO.create_tbl(con, csv_path; name = "no_assets")
        df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
        @test shape(df_org) == shape(df_res)
        # @show df_org[1:3, 1:5] df_res[1:3, 1:5]
        #
        # FIXME: cannot do an equality check b/c CSV.File above over
        # specifies column types:
        #
        #  Row │ name             type      active
        #      │ String31         String15  Bool
        # ─────┼───────────────────────────────────
        #    1 │ Asgard_Battery   storage     true
        #
        # instead of:
        #
        #  Row │ name             type      active
        #      │ String?          String?   Bool?
        # ─────┼───────────────────────────────────
        #    1 │ Asgard_Battery   storage     true

        @testset "temporary tables" begin
            tbl_name = TIO.create_tbl(con, csv_path; name = "tmp_assets", tmp = true)
            @test tbl_name in tmp_tbls(con)[!, :name]

            tbl_name = TIO.create_tbl(con, csv_path)
            @test tbl_name in tmp_tbls(con)[!, :name]
            @test tbl_name == "t_assets_data" # t_<cleaned up filename>
        end
    end

    @testset "table + CSV w/ alternatives -> table" begin
        opts = Dict(:on => [:name], :cols => [:investable])
        tbl_name = TIO.create_tbl(
            con,
            "no_assets",
            csv_copy;
            variant = "alt_assets",
            opts...,
            fill = false,
        )
        df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
        df_exp = DF.DataFrame(CSV.File(csv_copy; header = 2))
        @test df_exp.investable == df_res.investable
        @test df_org.investable != df_res.investable

        @testset "temporary tables" begin
            tbl_name = TIO.create_tbl(con, "no_assets", csv_copy; opts...)
            @test tbl_name in tmp_tbls(con)[!, :name]
            @test tbl_name == "t_assets_data_copy" # t_<cleaned up filename>
        end

        @testset "back-filling missing rows" begin
            tbl_name = TIO.create_tbl(
                con,
                "no_assets",
                csv_fill;
                variant = "alt_assets_filled",
                opts...,
                fill = true,
            )
            df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
            df_exp = DF.DataFrame(CSV.File(csv_copy; header = 2))
            # NOTE: row order is different, join to determine equality
            cmp = join_cmp(df_exp, df_res, ["name", "investable"]; on = :name)
            @test all(cmp.investable .== cmp.investable_1)
            @test cmp.source .== "both" |> all
        end

        @testset "back-filling missing rows w/ alternate values" begin
            tbl_name = TIO.create_tbl(
                con,
                "no_assets",
                csv_fill;
                variant = "alt_assets_filled_alt",
                opts...,
                fill = true,
                fill_values = Dict(:investable => true),
            )
            df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
            df_ref = DF.DataFrame(CSV.File(csv_fill; header = 2))
            cmp = join_cmp(df_res, df_ref, ["name", "investable"]; on = :name)
            @test subset(cmp, :investable_1 => ismissing).investable |> all
        end
    end
end

@testset "Set table column" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")
    csv_copy = replace(csv_path, "data.csv" => "data-copy.csv")
    csv_fill = replace(csv_path, "data.csv" => "data-alt.csv")

    df_org = DF.DataFrame(CSV.File(csv_path; header = 2))

    con = DBInterface.connect(DB)

    opts = Dict(:on => :name, :show => true)
    @testset "w/ vector" begin
        df_exp = DF.DataFrame(CSV.File(csv_copy; header = 2))
        df_res = TIO.set_tbl_col(con, csv_path, Dict(:investable => df_exp.investable); opts...)
        # NOTE: row order is different, join to determine equality
        cmp = join_cmp(df_exp, df_res, ["name", "investable"]; on = :name)
        investable = cmp[!, [c for c in propertynames(cmp) if occursin("investable", String(c))]]
        @test isequal.(investable[!, 1], investable[!, 2]) |> all

        # stupid Julia! grow up!
        args = [con, csv_path, Dict(:investable => df_exp.investable[2:end])]
        @test_throws DimensionMismatch TIO.set_tbl_col(args...; opts...)
        if (VERSION.major >= 1) && (VERSION.minor >= 8)
            @test_throws r"Length.+different" TIO.set_tbl_col(args...; opts...)
            @test_throws r"index.+value" TIO.set_tbl_col(args...; opts...)
        end
    end

    @testset "w/ constant" begin
        df_res = TIO.set_tbl_col(con, csv_path, Dict(:investable => true); opts...)
        @test df_res.investable |> all
    end

    @testset "w/ constant after filtering" begin
        where_clause = TIO.FmtSQL.@where_(lifetime in 25:50, name % "Valhalla_%")
        df_res = TIO.set_tbl_col(
            con,
            csv_path,
            Dict(:investable => true);
            opts...,
            where_ = where_clause,
        )
        @test shape(df_res) == shape(df_org)
        df_res =
            filter(row -> 25 <= row.lifetime <= 50 && startswith(row.name, "Valhalla_"), df_res)
        @test df_res.investable |> all
    end
end

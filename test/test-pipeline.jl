using CSV: CSV
using DataFrames: DataFrames, DataFrame
using DuckDB: DuckDB, DBInterface

function shape(df::DataFrame)
    return (DataFrames.nrow(df), DataFrames.ncol(df))
end

function tmp_tbls(con::DuckDB.DB)
    res = DBInterface.execute(con, "SELECT name FROM (SHOW ALL TABLES) WHERE temporary = true")
    return DataFrame(res)
end

"""
        join_cmp(df1, df2, cols; on::Union{Symbol, Vector{Symbol}})

When row order is different, do a join to determine equality; use the
columns `cols`, join on `on` (often :name).  The resulting DataFrame
is returned.  It uniquifies columns with clashing names (see
`?DataFrames.leftjoin`), and stores a "source" under the `:source` column.

"""
function join_cmp(df1, df2, cols; on::Union{Symbol, Vector{Symbol}})
    DataFrames.leftjoin(df1[!, cols], df2[!, cols]; on = on, makeunique = true, source = :source)
end

@testset "Utilities" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")

    @testset "get_tbl_name(source, tmp)" begin
        for (name, tmp) in [["my_file", false], ["t_my_file", true]]
            @test name == TulipaIO.get_tbl_name("path/my-file.csv", tmp)
        end
    end

    # redundant for the current implementation, needed when we support globs
    @testset "check_file(source)" begin
        @test TulipaIO.check_file(csv_path)
        @test !TulipaIO.check_file("not-there")
    end

    con = DBInterface.connect(DuckDB.DB)
    tbl_name = "mytbl"

    @testset "check_tbl(con, source)" begin
        DBInterface.execute(con, "CREATE TABLE $tbl_name AS SELECT * FROM range(5)")
        @test TulipaIO.check_tbl(con, tbl_name)
        @test !TulipaIO.check_tbl(con, "not_there")
    end

    @testset "Conditionally format source as SQL" begin
        read_ = TulipaIO.fmt_source(con, csv_path)
        @test occursin("read_csv", read_)
        @test occursin(csv_path, read_)
        read_ = TulipaIO.fmt_source(con, csv_path; skip = 1)
        @test occursin("skip=1", read_)
        @test TulipaIO.fmt_source(con, tbl_name) == tbl_name
        @test_throws TulipaIO.NeitherTableNorFileError TulipaIO.fmt_source(con, "not-there")
        if (VERSION.major >= 1) && (VERSION.minor >= 8)
            msg_re = r"not-there.+"
            msg_re *= "$con"
            @test_throws msg_re TulipaIO.fmt_source(con, "not-there")
        end
    end
end

@testset "Read CSV" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")
    csv_skip = replace(csv_path, "data.csv" => "data-extra-line.csv")
    csv_copy = replace(csv_path, "data.csv" => "data-copy.csv")
    csv_fill = replace(csv_path, "data.csv" => "data-alt.csv")

    df_org = DataFrame(CSV.File(csv_path))

    @testset "CSV -> DataFrame" begin
        con = DBInterface.connect(DuckDB.DB)
        df_res = TulipaIO.create_tbl(con, csv_path; show = true)
        @test shape(df_org) == shape(df_res)
        df_res = TulipaIO.create_tbl(con, csv_skip; show = true, skip = 1)
        @test shape(df_org) == shape(df_res)
        @test_throws TulipaIO.FileNotFoundError TulipaIO.create_tbl(con, "not-there")
        if (VERSION.major >= 1) && (VERSION.minor >= 8)
            @test_throws r"not-there" TulipaIO.create_tbl(con, "not-there")
        end
    end

    @testset "CSV -> DataFrame w/ a schema" begin
        con = DBInterface.connect(DuckDB.DB)
        mapping_csv_path = joinpath(DATA, "Norse/rep-periods-mapping.csv")
        col_schema = Dict(:period => "INT", :rep_period => "VARCHAR", :weight => "DOUBLE")
        TulipaIO.create_tbl(con, mapping_csv_path; types = col_schema)
        df_types = DuckDB.query(con, "DESCRIBE rep_periods_mapping") |> DataFrame
        @test df_types.column_name == ["period", "rep_period", "weight"]
        @test df_types.column_type == ["INTEGER", "VARCHAR", "DOUBLE"]
    end

    opts = Dict(:on => [:name], :cols => [:investable], :show => true)
    @testset "CSV w/ alternatives -> DataFrame" begin
        con = DBInterface.connect(DuckDB.DB)
        df_res = TulipaIO.create_tbl(con, csv_path, csv_copy; opts..., fill = false)
        df_exp = DataFrame(CSV.File(csv_copy))
        @test df_exp.investable == df_res.investable
        @test df_org.investable != df_res.investable
    end

    @testset "no filling for missing rows" begin
        con = DBInterface.connect(DuckDB.DB)
        df_res = TulipaIO.create_tbl(con, csv_path, csv_fill; opts..., fill = false)
        df_ref = DataFrame(CSV.File(csv_fill))
        # NOTE: row order is different, join to determine equality
        cmp = join_cmp(df_res, df_ref, ["name", "investable"]; on = :name)
        @test (
            DataFrames.subset(cmp, :investable_1 => DataFrames.ByRow(ismissing)).source .==
            "left_only"
        ) |> all
        @test (
            DataFrames.subset(cmp, :investable_1 => DataFrames.ByRow(!ismissing)).source .== "both"
        ) |> all
    end

    @testset "back-filling missing rows" begin
        con = DBInterface.connect(DuckDB.DB)
        df_res = TulipaIO.create_tbl(con, csv_path, csv_fill; opts..., fill = true)
        df_exp = DataFrame(CSV.File(csv_copy))
        cmp = join_cmp(df_exp, df_res, ["name", "investable"]; on = :name)
        @test all(cmp.investable .== cmp.investable_1)
        @test (cmp.source .== "both") |> all
    end

    @testset "back-filling missing rows w/ alternate values" begin
        con = DBInterface.connect(DuckDB.DB)
        df_res = TulipaIO.create_tbl(
            con,
            csv_path,
            csv_fill;
            opts...,
            fill = true,
            fill_values = Dict(:investable => true),
        )
        df_ref = DataFrame(CSV.File(csv_fill))
        cmp = join_cmp(df_res, df_ref, ["name", "investable"]; on = :name)
        @test (DataFrames.subset(cmp, :investable_1 => DataFrames.ByRow(ismissing)).investable) |>
              all
    end

    @testset "temporary tables" begin
        con = DBInterface.connect(DuckDB.DB)
        tbl_name = TulipaIO.create_tbl(con, csv_path; name = "tmp_assets", tmp = true)
        @test tbl_name in tmp_tbls(con)[!, :name]

        tbl_name = TulipaIO.create_tbl(con, csv_path; tmp = true)
        @test tbl_name == "t_assets_data" # t_<cleaned up filename>
        @test tbl_name in tmp_tbls(con)[!, :name]
    end

    @testset "CSV -> table" begin
        con = DBInterface.connect(DuckDB.DB)
        tbl_name = TulipaIO.create_tbl(con, csv_path; name = "no_assets")
        df_res = DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
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
    end

    @testset "table + CSV w/ alternatives -> table" begin
        # test setup
        con = DBInterface.connect(DuckDB.DB)
        TulipaIO.create_tbl(con, csv_path; name = "no_assets")

        opts = Dict(:on => [:name], :cols => [:investable])
        tbl_name = TulipaIO.create_tbl(
            con,
            "no_assets",
            csv_copy;
            name = "alt_assets",
            opts...,
            fill = false,
        )
        df_res = DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
        df_exp = DataFrame(CSV.File(csv_copy))
        @test df_exp.investable == df_res.investable
        @test df_org.investable != df_res.investable

        @testset "back-filling missing rows" begin
            tbl_name = TulipaIO.create_tbl(
                con,
                "no_assets",
                csv_fill;
                name = "alt_assets_filled",
                opts...,
                fill = true,
            )
            df_res = DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
            df_exp = DataFrame(CSV.File(csv_copy))
            # NOTE: row order is different, join to determine equality
            cmp = join_cmp(df_exp, df_res, ["name", "investable"]; on = :name)
            @test all(cmp.investable .== cmp.investable_1)
            @test (cmp.source .== "both") |> all
        end

        @testset "back-filling missing rows w/ alternate values" begin
            tbl_name = TulipaIO.create_tbl(
                con,
                "no_assets",
                csv_fill;
                name = "alt_assets_filled_alt",
                opts...,
                fill = true,
                fill_values = Dict(:investable => true),
            )
            df_res = DataFrame(DBInterface.execute(con, "SELECT * FROM $tbl_name"))
            df_ref = DataFrame(CSV.File(csv_fill))
            cmp = join_cmp(df_res, df_ref, ["name", "investable"]; on = :name)
            @test (
                DataFrames.subset(cmp, :investable_1 => DataFrames.ByRow(ismissing)).investable
            ) |> all
        end
    end
end

@testset "Set/replace a table column" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")
    csv_copy = replace(csv_path, "data.csv" => "data-copy.csv")
    csv_fill = replace(csv_path, "data.csv" => "data-alt.csv")

    df_org = DataFrame(CSV.File(csv_path))

    opts = Dict(:on => :name, :name => "dummy", :show => true)
    @testset "w/ vector" begin
        con = DBInterface.connect(DuckDB.DB)
        df_exp = DataFrame(CSV.File(csv_copy))
        df_res = TulipaIO.create_tbl(con, csv_path, Dict(:investable => df_exp.investable); opts...)
        # NOTE: row order is different, join to determine equality
        cmp = join_cmp(df_exp, df_res, ["name", "investable"]; on = :name)
        investable = cmp[!, [c for c in propertynames(cmp) if occursin("investable", String(c))]]
        @test isequal.(investable[!, 1], investable[!, 2]) |> all

        # stupid Julia! grow up!
        args = [con, csv_path, Dict(:investable => df_exp.investable[2:end])]
        @test_throws DimensionMismatch TulipaIO.create_tbl(args...; opts...)
        if (VERSION.major >= 1) && (VERSION.minor >= 8)
            @test_throws r"Length.+different" TulipaIO.create_tbl(args...; opts...)
            @test_throws r"index.+value" TulipaIO.create_tbl(args...; opts...)
        end
    end

    @testset "w/ constant" begin
        con = DBInterface.connect(DuckDB.DB)
        df_res = TulipaIO.create_tbl(con, csv_path, Dict(:investable => true); opts...)
        @test df_res.investable |> all

        table_name = TulipaIO.create_tbl(con, csv_path, Dict(:investable => true); on = :name)
        @test "assets_data" == table_name
    end

    @testset "w/ constant after filtering" begin
        con = DBInterface.connect(DuckDB.DB)
        where_clause = TulipaIO.FmtSQL.@where_(lifetime in 25:50, name % "Valhalla_%")
        df_res = TulipaIO.create_tbl(
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

@testset "Select from table" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")
    con = DBInterface.connect(DuckDB.DB)
    table_name = TulipaIO.create_tbl(con, csv_path)
    where_ = TulipaIO.FmtSQL.@where_(lifetime in 25:50, name % "Valhalla_%")
    df = TulipaIO.select_tbl(con, table_name, where_)
    @test all(i -> 25 <= i <= 50, df.lifetime)
    @test all(i -> startswith(i, "Valhalla_"), df.name)
end

@testset "Rename columns" begin
    con = DBInterface.connect(DuckDB.DB)
    tbl = "gibberish"
    query = "CREATE TABLE $(tbl) AS SELECT range, range+2 AS shifted FROM range(5)"
    DBInterface.execute(con, query)
    TulipaIO.rename_cols(con, tbl; range = "a", shifted = "b")
    df = DBInterface.execute(con, "SELECT * FROM $(tbl)") |> DataFrame
    @test ["a", "b"] == names(df)
end

@testset "Update table" begin
    csv_path = joinpath(DATA, "Norse/assets-data.csv")
    con = DBInterface.connect(DuckDB.DB)
    table_name = TulipaIO.create_tbl(con, csv_path)
    cols = Dict(:investable => true, :lifetime => 1)
    df = TulipaIO.update_tbl(con, table_name, cols; show = true)
    @test all(i -> i == 1, df.lifetime)
    @test all(df.investable)
    @test_throws TulipaIO.TableNotFoundError TulipaIO.update_tbl(con, "not_there", cols)
    if (VERSION.major >= 1) && (VERSION.minor >= 8)
        @test_throws r"not_there:.+not found" TulipaIO.update_tbl(con, "not_there", cols)
    end
end

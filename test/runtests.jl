import CSV
import DataFrames as DF
import DuckDB: DB, DBInterface

import TulipaIO

import Test: @test, @testset, @test_throws

const DATA = joinpath(@__DIR__, "data")

function shape(df::DF.DataFrame)
  return (DF.nrow(df), DF.ncol(df))
end

@testset "Read CSV" begin
  csv_path = joinpath(DATA, "Norse/assets-data.csv")
  con = DBInterface.connect(DB)

  df_org = DF.DataFrame(CSV.File(csv_path, header = 2))
  df_res = TulipaIO.read_csv(con, csv_path)
  @test shape(df_org) == shape(df_res)

  csv_copy = replace(csv_path, "data.csv" => "data-copy.csv")
  df_res = TulipaIO.read_csv_alt_cols(con, csv_path, csv_copy, on = ["name"], cols = ["investable"])
  df_exp = DF.DataFrame(CSV.File(csv_copy, header = 2))
  @test df_exp.investable == df_res.investable
  @test df_org.investable != df_res.investable
end

@testset "Import data into table" begin
  csv_path = joinpath(DATA, "Norse/assets-data.csv")
  con = DBInterface.connect(DB)

  df_org = DF.DataFrame(CSV.File(csv_path, header = 2))
  TulipaIO.create_tbl(con, "no_assets", csv_path)
  df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM no_assets"))
  @test shape(df_org) == shape(df_res)

  csv_copy = replace(csv_path, "data.csv" => "data-copy.csv")
  TulipaIO.create_alt_tbl(
    con,
    "no_assets",
    "alt_assets",
    csv_copy,
    on = ["name"],
    cols = ["investable"],
  )
  df_res = DF.DataFrame(DBInterface.execute(con, "SELECT * FROM alt_assets"))
  df_exp = DF.DataFrame(CSV.File(csv_copy, header = 2))
  @test df_exp.investable == df_res.investable
  @test df_org.investable != df_res.investable
end

```@meta
CurrentModule = TulipaIO
```

# TulipaIO

[TulipaIO](https://github.com/TulipaEnergy/TulipaIO.jl) is part of the Tulipa ecosystem of packages.
The main package in this ecosystem is [TulipaEnergyModel.jl](https://tulipaenergy.github.io/TulipaEnergyModel.jl/stable/).
Check that package first for more information on the ecosystem.

## Usage

TulipaIO is used to provide input to TulipaEnergyModel and other packages in the ecosystem.
Here is some basic usage:

First, we read a fake CSV file with the relevant information.

```@example basic
using TulipaIO: TulipaIO
using DuckDB: DBInterface, DB

con = DBInterface.connect(DB)
filepath = joinpath(@__DIR__, "..", "..", "test", "data", "Norse", "assets-data.csv") #hide
table_name = TulipaIO.create_tbl(con, filepath) # filepath is the path to a CSV
```

Then we can run SQL commands using the DuckDB interface.
It returns a `DuckDB.QueryResult`, which we convert to Dict to visualize:

```@example basic
DBInterface.execute(con, "SELECT name, variable_cost FROM $table_name WHERE type = 'conversion'") |> Dict
```

This allows simple conversion to DataFrame as well:

```@example basic
using DataFrames: DataFrame
DataFrame(DBInterface.execute(con, "SELECT name, type, investable, variable_cost FROM $table_name WHERE name LIKE 'Asgard_%'"))
```

## Contributors

```@raw html
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
```

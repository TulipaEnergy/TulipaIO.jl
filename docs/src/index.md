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
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/suvayu"><img src="https://avatars.githubusercontent.com/u/229540?v=4?s=100" width="100px;" alt="Suvayu Ali"/><br /><sub><b>Suvayu Ali</b></sub></a><br /><a href="#code-suvayu" title="Code">💻</a> <a href="#review-suvayu" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://abelsiqueira.com"><img src="https://avatars.githubusercontent.com/u/1068752?v=4?s=100" width="100px;" alt="Abel Soares Siqueira"/><br /><sub><b>Abel Soares Siqueira</b></sub></a><br /><a href="#code-abelsiqueira" title="Code">💻</a> <a href="#review-abelsiqueira" title="Reviewed Pull Requests">👀</a> <a href="#ideas-abelsiqueira" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/clizbe"><img src="https://avatars.githubusercontent.com/u/11889283?v=4?s=100" width="100px;" alt="Lauren Clisby"/><br /><sub><b>Lauren Clisby</b></sub></a><br /><a href="#code-clizbe" title="Code">💻</a> <a href="#review-clizbe" title="Reviewed Pull Requests">👀</a> <a href="#ideas-clizbe" title="Ideas, Planning, & Feedback">🤔</a> <a href="#projectManagement-clizbe" title="Project Management">📆</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/datejada"><img src="https://avatars.githubusercontent.com/u/12887482?v=4?s=100" width="100px;" alt="Diego Alejandro Tejada Arango"/><br /><sub><b>Diego Alejandro Tejada Arango</b></sub></a><br /><a href="#code-datejada" title="Code">💻</a> <a href="#review-datejada" title="Reviewed Pull Requests">👀</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
```

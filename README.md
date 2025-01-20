# TulipaIO

<!-- This check was disabled because these links don't exist until you push, create documentation, and create your first release -->
<!-- markdown-link-check-disable -->
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://TulipaEnergy.github.io/TulipaIO.jl/stable)
[![In development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://TulipaEnergy.github.io/TulipaIO.jl/dev)
[![Build Status](https://github.com/TulipaEnergy/TulipaIO.jl/workflows/Test/badge.svg)](https://github.com/TulipaEnergy/TulipaIO.jl/actions)
[![Test workflow status](https://github.com/TulipaEnergy/TulipaIO.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/TulipaEnergy/TulipaIO.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Lint workflow Status](https://github.com/TulipaEnergy/TulipaIO.jl/actions/workflows/Lint.yml/badge.svg?branch=main)](https://github.com/TulipaEnergy/TulipaIO.jl/actions/workflows/Lint.yml?query=branch%3Amain)
[![Docs workflow Status](https://github.com/TulipaEnergy/TulipaIO.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/TulipaEnergy/TulipaIO.jl/actions/workflows/Docs.yml?query=branch%3Amain)

[![Coverage](https://codecov.io/gh/TulipaEnergy/TulipaIO.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/TulipaEnergy/TulipaIO.jl)
[![DOI](https://zenodo.org/badge/DOI/FIXME)](https://doi.org/FIXME)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![All Contributors](https://img.shields.io/github/all-contributors/TulipaEnergy/TulipaIO.jl?labelColor=5e1ec7&color=c0ffee&style=flat-square))](#contributors)

## About `TulipaIO.jl` (`TIO`)

This package relies on [`DuckDB`](https://duckdb.org/docs/) to tie a
variety of data sources with Julia, and `TulipaEnergyModel` (`TEM`).
It also enables a bidirectional capability to manipulate datasets from
Julia and back to DuckDB.

A standard workflow requires a DuckDB connection, either to an
in-memory database, or to a database file.  Every data source is can
be made available in the database as a table, optionally importing it.
We can use SQL queries to transform and manipulate these tables into
something `TEM` can consume.  Thankfully we don't need to resort to
SQL every time.  `TIO` offers Julia functions that wrap common
transformations into a consistent API.  These functions can be chained
together to form a data processing pipeline.

The package also offers parsers for data formats like ESDL.

## How to Cite

If you use TulipaIO.jl in your work, please cite using the reference given in [CITATION.cff](https://github.com/TulipaEnergy/TulipaIO.jl/blob/main/CITATION.cff).

## Contributing

If you want to make contributions of any kind, please first take a look into TulipaEnergyModel's [contributing guide](https://github.com/TulipaEnergy/TulipaEnergyModel.jl/blob/main/docs/src/90-contributing.md) and [developer documentation](https://github.com/TulipaEnergy/TulipaEnergyModel.jl/blob/main/docs/src/91-developer.md).
Furthermore, you can read specific information for this package at the [TulipaIO's developer documentation](README.dev.md).

---

### Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/suvayu"><img src="https://avatars.githubusercontent.com/u/229540?v=4?s=100" width="100px;" alt="Suvayu Ali"/><br /><sub><b>Suvayu Ali</b></sub></a><br /><a href="#code-suvayu" title="Code">💻</a> <a href="#review-suvayu" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://abelsiqueira.com"><img src="https://avatars.githubusercontent.com/u/1068752?v=4?s=100" width="100px;" alt="Abel Soares Siqueira"/><br /><sub><b>Abel Soares Siqueira</b></sub></a><br /><a href="#code-abelsiqueira" title="Code">💻</a> <a href="#review-abelsiqueira" title="Reviewed Pull Requests">👀</a> <a href="#ideas-abelsiqueira" title="Ideas, Planning, & Feedback">🤔</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

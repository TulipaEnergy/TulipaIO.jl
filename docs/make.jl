using TulipaIO
using Documenter

DocMeta.setdocmeta!(TulipaIO, :DocTestSetup, :(using TulipaIO); recursive = true)

makedocs(;
    modules = [TulipaIO],
    doctest = true,
    linkcheck = true,
    authors = "Suvayu Ali <fatkasuvayu+linux@gmail.com> and contributors",
    repo = "https://github.com/TulipaEnergy/TulipaIO.jl/blob/{commit}{path}#{line}",
    sitename = "TulipaIO.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://TulipaEnergy.github.io/TulipaIO.jl",
        assets = ["assets/style.css"],
    ),
    pages = ["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(; repo = "github.com/TulipaEnergy/TulipaIO.jl", push_preview = true)

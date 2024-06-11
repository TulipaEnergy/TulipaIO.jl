var documenterSearchIndex = {"docs":
[{"location":"90-contributing/#contributing","page":"Contributing","title":"Contributing guidelines","text":"","category":"section"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"First of all, thanks for the interest!","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"We welcome all kinds of contribution, including, but not limited to code, documentation, examples, configuration, issue creating, etc.","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"Be polite and respectful, and follow the code of conduct.","category":"page"},{"location":"90-contributing/#Bug-reports-and-discussions","page":"Contributing","title":"Bug reports and discussions","text":"","category":"section"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"If you think you found a bug, feel free to open an issue. Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.","category":"page"},{"location":"90-contributing/#Working-on-an-issue","page":"Contributing","title":"Working on an issue","text":"","category":"section"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"If you found an issue that interests you, comment on that issue what your plans are. If the solution to the issue is clear, you can immediately create a pull request (see below). Otherwise, say what your proposed solution is and wait for a discussion around it.","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"tip: Tip\nFeel free to ping us after a few days if there are no responses.","category":"page"},{"location":"90-contributing/","page":"Contributing","title":"Contributing","text":"If your solution involves code (or something that requires running the package locally), check the developer documentation. Otherwise, you can use the GitHub interface directly to create your pull request.","category":"page"},{"location":"90-developer/#dev_docs","page":"Developer docs","title":"Developer documentation","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"note: Contributing guidelines\nIf you haven't, please read the Contributing guidelines first.","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"If you want to make contributions to this package that involves code, then this guide is for you.","category":"page"},{"location":"90-developer/#First-time-clone","page":"Developer docs","title":"First time clone","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"tip: If you have writing rights\nIf you have writing rights, you don't have to fork. Instead, simply clone and skip ahead. Whenever upstream is mentioned, use origin instead.","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"If this is the first time you work with this repository, follow the instructions below to clone the repository.","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Fork this repo\nClone your repo (this will create a git remote called origin)\nAdd this repo as a remote:\ngit remote add upstream https://github.com/TulipaEnergy/TulipaIO.jl","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"This will ensure that you have two remotes in your git: origin and upstream. You will create branches and push to origin, and you will fetch and update your local main branch from upstream.","category":"page"},{"location":"90-developer/#Linting-and-formatting","page":"Developer docs","title":"Linting and formatting","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Install a plugin on your editor to use EditorConfig. This will ensure that your editor is configured with important formatting settings.","category":"page"},{"location":"90-developer/#Testing","page":"Developer docs","title":"Testing","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"As with most Julia packages, you can just open Julia in the repository folder, activate the environment, and run test:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"julia> # press ]\npkg> activate .\npkg> test","category":"page"},{"location":"90-developer/#Working-on-a-new-issue","page":"Developer docs","title":"Working on a new issue","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"We try to keep a linear history in this repo, so it is important to keep your branches up-to-date.","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Fetch from the remote and fast-forward your local main\ngit fetch upstream\ngit switch main\ngit merge --ff-only upstream/main\nBranch from main to address the issue (see below for naming)\ngit switch -c 42-add-answer-universe\nPush the new local branch to your personal remote repository\ngit push -u origin 42-add-answer-universe\nCreate a pull request to merge your remote branch into the org main.","category":"page"},{"location":"90-developer/#Branch-naming","page":"Developer docs","title":"Branch naming","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"If there is an associated issue, add the issue number.\nIf there is no associated issue, and the changes are small, add a prefix such as \"typo\", \"hotfix\", \"small-refactor\", according to the type of update.\nIf the changes are not small and there is no associated issue, then create the issue first, so we can properly discuss the changes.\nUse dash separated imperative wording related to the issue (e.g., 14-add-tests, 15-fix-model, 16-remove-obsolete-files).","category":"page"},{"location":"90-developer/#Commit-message","page":"Developer docs","title":"Commit message","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Use imperative or present tense, for instance: Add feature or Fix bug.\nHave informative titles.\nWhen necessary, add a body with details.\nIf there are breaking changes, add the information to the commit message.","category":"page"},{"location":"90-developer/#Before-creating-a-pull-request","page":"Developer docs","title":"Before creating a pull request","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"tip: Atomic git commits\nTry to create \"atomic git commits\" (recommended reading: The Utopic Git History).","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Make sure the tests pass.\nFetch any main updates from upstream and rebase your branch, if necessary:\ngit fetch upstream\ngit rebase upstream/main BRANCH_NAME\nThen you can open a pull request and work with the reviewer to address any issues.","category":"page"},{"location":"90-developer/#Building-and-viewing-the-documentation-locally","page":"Developer docs","title":"Building and viewing the documentation locally","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Following the latest suggestions, we recommend using LiveServer to build the documentation. Here is how you do it:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Run julia --project=docs to open Julia in the environment of the docs.\nIf this is the first time building the docs\nPress ] to enter pkg mode\nRun pkg> dev . to use the development version of your package\nPress backspace to leave pkg mode\nRun julia> using LiveServer\nRun julia> servedocs()","category":"page"},{"location":"90-developer/#Making-a-new-release","page":"Developer docs","title":"Making a new release","text":"","category":"section"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"To create a new release, you can follow these simple steps:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Create a branch release-x.y.z\nUpdate version in Project.toml\nUpdate the CHANGELOG.md:\nRename the section \"Unreleased\" to \"[x.y.z] - yyyy-mm-dd\" (i.e., version under brackets, dash, and date in ISO format)\nAdd a new section on top of it named \"Unreleased\"\nAdd a new link in the bottom for version \"x.y.z\"\nChange the \"[unreleased]\" link to use the latest version - end of line, vx.y.z ... HEAD.\nCreate a commit \"Release vx.y.z\", push, create a PR, wait for it to pass, merge the PR.\nGo back to main screen and click on the latest commit (link: https://github.com/TulipaEnergy/TulipaIO.jl/commit/main)\nAt the bottom, write @JuliaRegistrator register","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"After that, you only need to wait and verify:","category":"page"},{"location":"90-developer/","page":"Developer docs","title":"Developer docs","text":"Wait for the bot to comment (should take < 1m) with a link to a RP to the registry\nFollow the link and wait for a comment on the auto-merge\nThe comment should said all is well and auto-merge should occur shortly\nAfter the merge happens, TagBot will trigger and create a new GitHub tag. Check on https://github.com/TulipaEnergy/TulipaIO.jl/releases\nAfter the release is create, a \"docs\" GitHub action will start for the tag.\nAfter it passes, a deploy action will run.\nAfter that runs, the stable docs should be updated. Check them and look for the version number.","category":"page"},{"location":"90-reference/#reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"90-reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"90-reference/","page":"Reference","title":"Reference","text":"Pages = [\"90-reference.md\"]","category":"page"},{"location":"90-reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"90-reference/","page":"Reference","title":"Reference","text":"Pages = [\"90-reference.md\"]","category":"page"},{"location":"90-reference/","page":"Reference","title":"Reference","text":"Modules = [TulipaIO]","category":"page"},{"location":"90-reference/#Base.merge-Tuple","page":"Reference","title":"Base.merge","text":"merge(args...)\n\nGiven a set of structs, merge them and return a single struct.  Fields are merged when they are equal or nothing.  Anything else raises an error with a summary of the fields with conflicting values.\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.create_tbl-Tuple{DuckDB.DB, String, String}","page":"Reference","title":"TulipaIO.create_tbl","text":"create_tbl(\n    con::DB,\n    base_source::String,\n    alt_source::String;\n    on::Vector{Symbol},\n    cols::Vector{Symbol},\n    variant::String = \"\",\n    fill::Bool = true,\n    fill_values::Union{Missing,Dict} = missing,\n    tmp::Bool = false,\n    show::Bool = false,\n)\n\nCreate a table from two sources.  The first is used as the base, and the second source is used as a source for alternative values by doing a LEFT JOIN, i.e. all rows in the base source are retained.\n\nEither sources can be a table in DuckDB, or a file source as in the single source variant.\n\nThe resulting table is saved as the table variant.  The name of the created table is returned.  The behaviour for tmp, and show are identical to the single source variant.\n\nThe LEFT JOIN is performend on the columns specified by on.  The set of columns picked from the alternative source after the join are specified by cols.\n\nIf the alternate source has a subset of rows, the default behaviour is to back-fill the corresponding values from the base table.  If this is not desired, then fill can be set to false.  In that case they will be missing values.\n\nTo fill an alternate value, you can set fill_values to a dictionary, where the keys are column names, and the values are the corresponding fill value.  If any columns are missing, it falls back to back-fill.\n\nTODO: In the future an \"error\" option would also be supported, to fail loudly when the number of rows do not match between the base and alternative source.\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.create_tbl-Tuple{DuckDB.DB, String}","page":"Reference","title":"TulipaIO.create_tbl","text":"create_tbl(\n    con::DB,\n    source::String;\n    name::String = \"\",\n    tmp::Bool = false,\n    show::Bool = false,\n)\n\nCreate a table from a file source (CSV, Parquet, line delimited JSON, etc)\n\nThe resulting table is saved as the table name.  The name of the created table is returned.\n\nOptionally, if show is true, the table is returned as a Julia DataFrame.  This can be useful for interactive debugging in the Julia REPL.\n\nIt is also possible to create the table as a temporary table by setting the tmp flag, i.e. the table is session scoped.  It is deleted when you close the connection with DuckDB.\n\nWhen show is false, and name was not provided, a table name autotomatically generated from the basename of the filename is used. This also unconditionally sets the temporary table flag to true.\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.flow_from_json-Tuple{Any}","page":"Reference","title":"TulipaIO.flow_from_json","text":"flow_from_json(json)\n\nReturns an array of from/to node names from a JSON document (as parsed by JSON3.jl):\n\n[(from_name, to_name, Asset(...)), (..., ..., ...), ...]\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.flow_from_json_impl!-Tuple{JSON3.Object, Any}","page":"Reference","title":"TulipaIO.flow_from_json_impl!","text":"flow_from_json_impl!(json, flows; find_edge)\n\nFind all flows (from/to node names) from a JSON document.\n\njson: JSON document\nflows: The flows are returned by appending to this vector\nfind_edge: Function invoked as find_edge(asset::JSON3.Object) to find the flows originating from an asset\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.json_get-Tuple{Any, String}","page":"Reference","title":"TulipaIO.json_get","text":"json_get(json, reference; trunc = 0)\n\nGiven a JSON document, find the object pointed to by the reference (e.g. \"//@<key>.<array_idx>/@<key>\"); truncate the last trunc components of the reference.\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.read_esdl_json-Tuple{Any}","page":"Reference","title":"TulipaIO.read_esdl_json","text":"read_esdl_json(json_path)\n\nThis is the entry point for the parser.  It reads the ESDL JSON file at json_path and returns an array of from/to node names, along with a struct of Asset type.  The Asset attribute values are determined by combining the attribute values of the from & to ESDL assets nodes.  If the two nodes have conflicting asset values, an error is raised:\n\n[(from_name, to_name, Asset(...)), (..., ..., ...), ...]\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.reduce_unless-Tuple{Any, Any}","page":"Reference","title":"TulipaIO.reduce_unless","text":"reduce_unless(fn, itr; init, sentinel)\n\nA version of reduce that stops if reduction returns sentinel at any point\n\nfn: reduction function\nitr: iterator to reduce\ninit: initial value (unlike standard, mandatory)\nsentinel: stop if reduction returns sentinel\n\nReturns reduced value, or sentinel\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.resolve!-Tuple{Any, Any, Any}","page":"Reference","title":"TulipaIO.resolve!","text":"resolve!(field, values, errs)\n\nGiven a set of values, ensure they are either all equal or nothing.  On failure, push field to errs.\n\nfield: the field to push in errs to signal failure\nvalues: values to check\nerrs: vector of field names with errors\n\nReturns resolved value\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.set_tbl_col-Union{Tuple{T}, Tuple{DuckDB.DB, String, Dict{Symbol, T}}} where T","page":"Reference","title":"TulipaIO.set_tbl_col","text":"set_tbl_col(\n    con::DB,\n    source::String,\n    cols::Dict{Symbol, T};\n    on::Symbol,\n    col::Symbol,\n    where_::String = \"\",\n    variant::String = \"\",\n    tmp::Bool = false,\n    show::Bool = false,\n) where T\n\nCreate a table from a source (either a DuckDB table or a file), where a column can be set to the value provided by value.  Unlike the vector variant of this function, all values of the column are set to this value.\n\nAll other options and behaviour are same as the vector variant of this function.\n\n\n\n\n\n","category":"method"},{"location":"90-reference/#TulipaIO.set_tbl_col-Union{Tuple{T}, Tuple{DuckDB.DB, String, Dict{Symbol, Vector{T}}}} where T<:Union{Bool, Float64, Int64, String}","page":"Reference","title":"TulipaIO.set_tbl_col","text":"set_tbl_col(\n    con::DB,\n    source::String,\n    cols::Dict{Symbol,Vector{T}};\n    on::Symbol,\n    variant::String = \"\",\n    tmp::Bool = false,\n    show::Bool = false,\n) where T <: Union{Int64, Float64, String, Bool}\n\nCreate a table from a source (either a DuckDB table or a file), where a column can be set to the vector provided by vals.  This transform is very similar to create_tbl, except that the alternate source is a data structure in Julia.\n\nThe resulting table is saved as the table name.  The name of the created table is returned.\n\nAll other options behave as the two source version of create_tbl.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = TulipaIO","category":"page"},{"location":"#TulipaIO","page":"Home","title":"TulipaIO","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"TulipaIO is part of the Tulipa ecosystem of packages. The main package in this ecosystem is TulipaEnergyModel.jl. Check that package first for more information on the ecosystem.","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"TulipaIO is used to provide input to TulipaEnergyModel and other packages in the ecosystem. Here is some basic usage:","category":"page"},{"location":"","page":"Home","title":"Home","text":"First, we read a fake CSV file with the relevant information.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TulipaIO: TulipaIO\nusing DuckDB: DBInterface, DB\n\ncon = DBInterface.connect(DB)\nfilepath = joinpath(@__DIR__, \"..\", \"..\", \"test\", \"data\", \"Norse\", \"assets-data.csv\") #hide\ntable_name = TulipaIO.create_tbl(con, filepath) # filepath is the path to a CSV","category":"page"},{"location":"","page":"Home","title":"Home","text":"Then we can run SQL commands using the DuckDB interface. It returns a DuckDB.QueryResult, which we convert to Dict to visualize:","category":"page"},{"location":"","page":"Home","title":"Home","text":"DBInterface.execute(con, \"SELECT name, variable_cost FROM $table_name WHERE type = 'conversion'\") |> Dict","category":"page"},{"location":"","page":"Home","title":"Home","text":"This allows simple conversion to DataFrame as well:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using DataFrames: DataFrame\nDataFrame(DBInterface.execute(con, \"SELECT name, type, investable, variable_cost FROM $table_name WHERE name LIKE 'Asgard_%'\"))","category":"page"}]
}

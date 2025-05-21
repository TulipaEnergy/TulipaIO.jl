export read_csv_folder, show_tables, get_table

"""
    read_csv_folder(connection, folder; kwargs...)

Read all CSV files in the `folder` and create a table for each in the `connection`.

## Keywords arguments

- `database_schema = ""`
- `table_name_prefix = ""`
- `table_name_suffix = ""`
- `schemas = Dict()` Dictionary of dictionaries, where the inner
  dictionary is a table schema (partial schemas are allowed).  The
  keys of the outer dictionary are the table names (without prefix and suffix)
- kwargs... are keyword options that are passed on to DuckDB's `read_csv` function
"""
function read_csv_folder(
    connection,
    folder;
    database_schema = "",
    table_name_prefix = "",
    table_name_suffix = "",
    replace_if_exists = true,
    require_schema = false,
    schemas = Dict(),
    kwargs...,
)
    if length(database_schema) > 0
        DBInterface.execute(connection, "CREATE SCHEMA IF NOT EXISTS $database_schema")
    end
    for filename in readdir(folder)
        if !endswith(".csv")(filename)
            continue
        end
        table_name, _ = splitext(filename)
        table_name = replace(table_name, "-" => "_")

        types = Dict()
        if !haskey(schemas, table_name)
            if require_schema
                error(
                    "No `$table_name` in given `schemas`. Use `require_schema = false` if you want to skip it.",
                )
            else
                @debug "No `$table_name` in given `schemas`. Ignoring because `require_schema = false`."
            end
        else
            types = schemas[table_name]
        end

        table_name = "$table_name_prefix$table_name$table_name_suffix"
        if length(database_schema) > 0
            table_name = "$database_schema.$table_name"
        end

        create_tbl(
            connection,
            joinpath(folder, filename);
            name = table_name,
            types,
            replace_if_exists,
            kwargs...,
        )
    end

    return connection
end

"""
    df = show_tables(connection)
    query = show_tables(Val(:raw), connection)

Run the `SHOW TABLES` sql command.

The `Val(:raw)` variant returns the raw output from DuckDB, otherwise we construct a DataFrame.
"""
function show_tables(::Val{:raw}, connection)
    DBInterface.execute(connection, "SHOW TABLES")
end

"""
    df = get_table(connection, table_name)
    query = get_table(Val(:raw), connection, table_name)

Run the `SELECT * FROM table_name` sql command.

The `Val(:raw)` variant returns the raw output from DuckDB, otherwise we construct a DataFrame.
"""
function get_table(::Val{:raw}, connection, table_name)
    DBInterface.execute(connection, "SELECT * FROM $table_name")
end

for foo in (:show_tables, :get_table)
    @eval begin
        $foo(con::DBInterface.Connection, args...; kwargs...) =
            DF.DataFrame($foo(Val(:raw), con, args...; kwargs...))
    end
end

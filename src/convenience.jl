export read_csv_folder, show_tables, get_table

"""
    read_csv_folder(connection, folder)

Read all CSV files in the `folder` and create a table for each in the `connection`.

## Keywords arguments

- `table_name_prefix = ""`
- `table_name_suffix = ""`
- `schemas = Dict()` Dictionary of dictionaries, where the inner
  dictionary is a table schema (partial schemas are allowed).  The
  keys of the outer dictionary are the table names
- opts... are keyword options that are passed on to DuckDB's `read_csv` function
"""
function read_csv_folder(
    connection,
    folder;
    table_name_prefix = "",
    table_name_suffix = "",
    schemas = Dict(),
    opts...,
)
    for filename in readdir(folder)
        if !endswith(".csv")(filename)
            continue
        end
        table_name, _ = splitext(filename)
        table_name = replace(table_name, "-" => "_")
        table_name = table_name_prefix * table_name * table_name_suffix

        types = get(schemas, table_name, Dict())
        create_tbl(connection, joinpath(folder, filename); name = table_name, types, opts...)
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

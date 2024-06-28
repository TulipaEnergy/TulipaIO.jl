export read_csv_folder

"""
    read_csv_folder(connection, folder)

Read all CSV files in the `folder` and create a table for each in the `connection`.

## Keywords arguments

- `table_name_prefix = ""`
- `table_name_suffix = ""`
"""
function read_csv_folder(connection, folder; table_name_prefix = "", table_name_suffix = "")
    for filename in readdir(folder)
        if !endswith(".csv")(filename)
            continue
        end
        table_name, _ = splitext(filename)
        table_name = replace(table_name, "-" => "_")
        table_name = table_name_prefix * table_name * table_name_suffix
        create_tbl(connection, joinpath(folder, filename); name = table_name)
    end

    return connection
end

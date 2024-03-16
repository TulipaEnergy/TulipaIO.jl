import DuckDB: DB

struct FileNotFoundError <: Exception
    file::String
    msg::String
    function FileNotFoundError(file)
        if ispath(file)
            new(file, "$(file): exists, but not a regular file")
        else
            new(file, "$(file): file not found")
        end
    end
end

struct DirectoryNotFoundError <: Exception
    dir::String
    msg::String
    function DirectoryNotFoundError(dir)
        if ispath(dir)
            new(dir, "$(dir): exists, but not a directory")
        else
            new(dir, "$(dir): directory not found")
        end
    end
end

struct TableNotFoundError <: Exception
    con::DB
    tbl::String
    msg::String
    TableNotFoundError(con, tbl) = new(con, tbl, "$(tbl): table not found in $(con)")
end

struct NeitherTableNorFileError <: Exception
    con::DB
    src::String
    msg::String
    NeitherTableNorFileError(con, src, msg) =
        new(con, src, "$(src): neither table ($con) nor file found")
end

Base.showerror(io::IO, exc::FileNotFoundError) = print(io, exc.msg)
Base.showerror(io::IO, exc::DirectoryNotFoundError) = print(io, exc.msg)
Base.showerror(io::IO, exc::TableNotFoundError) = print(io, exc.msg)
Base.showerror(io::IO, exc::NeitherTableNorFileError) = print(io, exc.msg)

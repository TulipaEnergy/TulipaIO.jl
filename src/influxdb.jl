module InfluxDB

using JSON3: JSON3
using HTTP: HTTP
import DataFrames as DF
import Dates: DateTime

# NOTE: this doesn't actually do anything smart like batching
# or keeping an open connection, it just remembers the connection
# details
struct InfluxDBClient
    host::String
    database::String
    port::Int
    path::String
    username::String
    password::String
end

InfluxDBClient(host::String, database::String) =
    InfluxDBClient(host, database, 8086, "query", "", "")

function query(
    client::InfluxDBClient,
    measurement::String,
    time_range_start::DateTime,
    time_range_end::DateTime,
)
    # NOTE: the query is not escaped, so no untrusted input should be accepted here
    db_query = "SELECT time, value FROM \"$measurement\" WHERE time >= $time_range_start AND time <= $time_range_end"
    url_params = ["db" => client.database, "q" => db_query]
    uri = HTTP.URI(;
        scheme = "http",
        host = client.host,
        path = client.path,
        port = client.port,
        query = url_params,
    )

    response = HTTP.get(uri)
    parsed = JSON3.read(response.body)

    rows = parsed["results"][1]["series"][1]["values"]
    columns = [[x[1] for x in rows], [x[2] for x in rows]]
    df = DF.DataFrame(columns, parsed["results"][1]["series"][1]["columns"])
    return df
end

end

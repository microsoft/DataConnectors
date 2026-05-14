(parameter) =>
let
    SelectRows = Table.SelectRows(parameter[taxi_table], each [store_and_fwd_flag] = true),
    SelectColumns = Table.SelectColumns(SelectRows, { "lpep_dropoff_datetime", "DOLocationID" }),
    Sort = Table.Sort(SelectColumns, {"DOLocationID"}),
    FirstN = Table.FirstN(Sort, 2)
in
    FirstN
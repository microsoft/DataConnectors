(parameter) => 
let
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    SelectColumns = Table.SelectColumns(Sorted, {"lpep_pickup_datetime"}),
    WhereAlwaysTrue = Table.SelectRows(SelectColumns, each [lpep_pickup_datetime] <= #datetime(2023, 2, 3, 1, 0, 0.0)),
    FirstN = Table.FirstN(WhereAlwaysTrue, 1)
in
    FirstN
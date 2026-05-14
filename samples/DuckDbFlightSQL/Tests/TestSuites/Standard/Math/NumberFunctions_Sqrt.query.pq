(parameter) =>
let
    Columns = [
        SQRT = each Number.RoundDown(Number.Sqrt([fare_amount]), 5)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "SQRT", Columns[SQRT]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"SQRT"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

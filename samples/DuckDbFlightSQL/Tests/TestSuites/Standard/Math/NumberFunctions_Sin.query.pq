(parameter) =>
let
    Columns = [
        SIN = each Number.RoundDown(Number.Sin([fare_amount]),5)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "SIN", Columns[SIN]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"SIN"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

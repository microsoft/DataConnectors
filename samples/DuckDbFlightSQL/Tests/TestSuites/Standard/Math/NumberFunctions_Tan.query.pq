(parameter) =>
let
    Columns = [
        TAN = each Number.RoundDown(Number.Tan([fare_amount]), 5)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "TAN", Columns[TAN]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"TAN"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

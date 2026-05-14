(parameter) =>
let
    Columns = [
        ABS = each Number.Abs([fare_amount])
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "ABS", Columns[ABS]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"ABS"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

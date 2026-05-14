(parameter) =>
let
    Columns = [
        ROUND = each Number.Round([fare_amount])
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "ROUND", Columns[ROUND]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"ROUND"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

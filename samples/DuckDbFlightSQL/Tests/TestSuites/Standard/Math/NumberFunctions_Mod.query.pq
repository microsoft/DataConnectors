(parameter) =>
let
    Columns = [
        MOD = each Number.Mod([fare_amount], 2)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "MOD", Columns[MOD]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"MOD"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

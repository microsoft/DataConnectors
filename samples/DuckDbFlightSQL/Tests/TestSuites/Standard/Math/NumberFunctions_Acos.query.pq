(parameter) =>
let
    Columns = [
        ACOS = each Number.Acos([fare_amount] / [fare_amount])
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "ACOS", Columns[ACOS]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"ACOS"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

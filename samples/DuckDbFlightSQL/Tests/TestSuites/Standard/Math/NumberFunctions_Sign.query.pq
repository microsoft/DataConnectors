(parameter) =>
let
    Columns = [
        SIGN = each Number.Sign([fare_amount])
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "SIGN", Columns[SIGN]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"SIGN"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

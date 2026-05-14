(parameter) =>
let
    Columns = [
        ROUNDDIGITS = each Number.Round([fare_amount], 1)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "ROUNDDIGITS", Columns[ROUNDDIGITS]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"ROUNDDIGITS"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

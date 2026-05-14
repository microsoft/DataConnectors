(parameter) =>
let
    Columns = [
        FLOOR = each Number.RoundDown([fare_amount])
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "FLOOR", Columns[FLOOR]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"FLOOR"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

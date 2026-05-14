(parameter) =>
let
    Columns = [
        ATAN = each Number.RoundDown(Number.Atan([fare_amount]),5)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "ATAN", Columns[ATAN]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"ATAN"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

(parameter) =>
let
    Columns = [
        POWER = each Number.Power([fare_amount] / [fare_amount], 3)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "POWER", Columns[POWER]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"POWER"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

(parameter) =>
let
    Columns = [
        COS = each Number.RoundDown(Number.Cos([fare_amount]),5)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "COS", Columns[COS]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"COS"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

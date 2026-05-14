(parameter) =>
let
    Columns = [
        ASIN = each Number.RoundDown(Number.Asin([fare_amount] / [fare_amount]),5)
    ],
    SelectColumns = Table.SelectColumns(SelectRows, {"ASIN"}),
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "ASIN", Columns[ASIN]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

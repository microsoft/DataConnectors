(parameter) =>
let
    Columns = [
        CEILING = each Number.RoundUp([fare_amount]),
        CEILING2 = each Number.RoundUp([fare_amount], 2)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "CEILING", Columns[CEILING]),
    AddColumns2 = Table.AddColumn(AddColumns, "CEILING2", Columns[CEILING2]),
    SelectRows = Table.SelectRows(AddColumns2, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"fare_amount", "CEILING", "CEILING2"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

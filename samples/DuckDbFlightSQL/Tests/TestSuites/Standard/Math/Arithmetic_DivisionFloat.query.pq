(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table],{"fare_amount", Order.Descending}),
    AddCol = Table.AddColumn(Sorted, "DivisionFloat", each Number.Round(([fare_amount] / 90.0), 8)),
    SelectRows = Table.SelectRows(AddCol, each [PULocationID] = 193),
    SelectColumns = Table.SelectColumns(SelectRows, {"DivisionFloat"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table],{"fare_amount", Order.Descending}),
    AddCol = Table.AddColumn(Sorted, "DivisionInteger", each Number.Round(([PULocationID] / 90), 8)),
    SelectRows = Table.SelectRows(AddCol, each [PULocationID] = 193),
    SelectColumns = Table.SelectColumns(SelectRows, {"DivisionInteger"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

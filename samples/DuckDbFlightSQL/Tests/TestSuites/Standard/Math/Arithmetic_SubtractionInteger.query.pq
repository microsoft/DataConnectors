(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table],{"fare_amount", Order.Descending}),
    AddCol = Table.AddColumn(Sorted, "SubtractionInteger", each [PULocationID] - 90),
    SelectRows = Table.SelectRows(AddCol, each [PULocationID] = 193),
    SelectColumns = Table.SelectColumns(SelectRows, {"SubtractionInteger"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

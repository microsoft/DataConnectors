(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table],{"fare_amount", Order.Descending}),
    AddCol = Table.AddColumn(Sorted, "AdditionFloat", each [fare_amount] + 90),
    SelectRows = Table.SelectRows(AddCol, each [PULocationID] = 193),
    SelectColumns = Table.SelectColumns(SelectRows, {"AdditionFloat"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

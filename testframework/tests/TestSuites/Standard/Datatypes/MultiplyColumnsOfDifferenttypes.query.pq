(parameter) =>
let
    AddColumns = Table.AddColumn(parameter[taxi_table], "Custom", each Number.Round(([payment_type] * [fare_amount]), 2)),
    SelectColumns = Table.SelectColumns(AddColumns, { "lpep_pickup_datetime", "Custom" }),
    Sort = Table.Sort(SelectColumns, { { "lpep_pickup_datetime", Order.Ascending } }),
    FirstN = Table.FirstN(Sort, 2)
in
    FirstN
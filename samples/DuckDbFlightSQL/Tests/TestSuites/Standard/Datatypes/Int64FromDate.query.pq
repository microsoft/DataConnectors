(parameter) =>
let
    TBL = Table.AddColumn(parameter[taxi_date_table], "Custom", each Int64.From([lpep_pickup_date])),
    Sorted = Table.Sort(TBL, {"RecordID", Order.Descending}),
    Custom = Table.SelectColumns(Sorted, {"lpep_pickup_date","Custom"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
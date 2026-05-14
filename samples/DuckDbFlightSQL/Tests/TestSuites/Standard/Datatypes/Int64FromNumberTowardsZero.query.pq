(parameter) =>
let
    TBL = Table.AddColumn(parameter[taxi_table], "Custom", each Int64.From([trip_distance], null,RoundingMode.TowardZero)),
    Sorted = Table.Sort(TBL, {"RecordID", Order.Descending}),
    Custom = Table.SelectColumns(Sorted, {"trip_distance","Custom"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
(parameter) =>
let
    TBL = Table.AddColumn(parameter[taxi_table], "Custom", each Int32.From([RecordID])),
    Sorted = Table.Sort(TBL, {"RecordID", Order.Descending}),
    Custom = Table.SelectColumns(Sorted, {"Custom"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
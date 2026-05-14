(parameter) =>
let
    TBL = Table.AddColumn(parameter[taxi_table], "Custom", each Decimal.From([total_amount])),
    Sorted = Table.Sort(TBL, "RecordID"),
    Custom = Table.SelectColumns(Sorted, {"Custom"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
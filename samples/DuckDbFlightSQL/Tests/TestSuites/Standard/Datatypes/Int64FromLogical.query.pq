(parameter) =>
let
    TBL = Table.AddColumn(parameter[misc_table], "Custom", each Int64.From([BOOLEANFIELD])),
    Sorted = Table.Sort(TBL, {"INTEGERFIELD", Order.Descending}),
    Custom = Table.SelectColumns(Sorted, {"BOOLEANFIELD","Custom"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
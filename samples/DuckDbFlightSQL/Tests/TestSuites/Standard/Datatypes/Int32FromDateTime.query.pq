(parameter) =>
let
    TBL = Table.AddColumn(parameter[misc_table], "Custom", each Int32.From([DATETIMEFIELD])),
    Sorted = Table.Sort(TBL, {"INTEGERFIELD", Order.Descending}),
    Custom = Table.SelectColumns(Sorted, {"DATETIMEFIELD","Custom"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
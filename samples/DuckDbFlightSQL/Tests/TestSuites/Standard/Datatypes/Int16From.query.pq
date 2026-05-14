(parameter) =>
let
    TBL = Table.AddColumn(parameter[taxi_table], "Custom", each Int16.From([RecordID])),
    Sorted = Table.Sort(TBL, "RecordID"),
    Custom = Table.SelectColumns(Sorted, {"Custom"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
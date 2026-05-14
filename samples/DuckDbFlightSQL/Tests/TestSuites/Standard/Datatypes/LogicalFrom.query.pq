(parameter) =>
let
    TBL = Table.AddColumn(parameter[taxi_table], "Custom", each Logical.From([store_and_fwd_flag])),
    Sorted = Table.Sort(TBL,"RecordID"),
    Custom = Table.SelectColumns(Sorted, {"store_and_fwd_flag","Custom"}),
    FirstN = Table.FirstN(Custom, 5)
in
    Table.Buffer(FirstN)
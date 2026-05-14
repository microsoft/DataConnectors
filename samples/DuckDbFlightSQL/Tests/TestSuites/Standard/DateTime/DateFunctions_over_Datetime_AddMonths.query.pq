(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T6 = Table.AddColumn(T3, "M+1", each Date.AddMonths([lpep_dropoff_datetime], 1)),
    T9 = Table.FirstN(T6, 1)
in
    Table.Buffer(T9)

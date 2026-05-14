(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T8 = Table.AddColumn(T3, "D+1", each Date.AddDays([lpep_dropoff_datetime], 1)),
    T9 = Table.FirstN(T8, 1)
in
    T9

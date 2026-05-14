(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "Y+1", each Date.AddYears([lpep_dropoff_datetime], 1)),
    T9 = Table.FirstN(T4, 1)
in
    T9

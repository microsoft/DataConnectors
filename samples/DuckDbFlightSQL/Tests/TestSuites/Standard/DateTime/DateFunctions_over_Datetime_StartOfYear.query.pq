(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "SOY", each Date.StartOfYear([lpep_dropoff_datetime])),
    T8 = Table.FirstN(T4, 1)
in
    T8

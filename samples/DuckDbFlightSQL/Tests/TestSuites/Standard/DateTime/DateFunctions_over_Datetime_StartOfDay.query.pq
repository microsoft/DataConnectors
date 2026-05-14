(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T7 = Table.AddColumn(T3, "SOD", each Date.StartOfDay([lpep_dropoff_datetime])),
    T8 = Table.FirstN(T7, 1)
in
    T8

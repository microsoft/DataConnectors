(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T5 = Table.AddColumn(T3, "SOQ", each Date.StartOfQuarter([lpep_dropoff_datetime])),
    T8 = Table.FirstN(T5, 1)
in
    T8

(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T6 = Table.AddColumn(T3, "SOM", each Date.StartOfMonth([lpep_dropoff_datetime])),
    T8 = Table.FirstN(T6, 1)
in
    T8

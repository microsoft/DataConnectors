(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T6 = Table.AddColumn(T3, "SOM", each Date.StartOfMonth([lpep_pickup_date])),
    TE = Table.FirstN(T6, 1)
in
    TE

(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T8 = Table.AddColumn(T3, "SOD", each Date.StartOfDay([lpep_pickup_date])),
    TE = Table.FirstN(T8, 1)
in
    TE

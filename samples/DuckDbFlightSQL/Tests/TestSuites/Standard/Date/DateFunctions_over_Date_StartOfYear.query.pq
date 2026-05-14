(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "SOY", each Date.StartOfYear([lpep_pickup_date])),
    TE = Table.FirstN(T4, 1)
in
    TE

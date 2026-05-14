(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T5 = Table.AddColumn(T3, "SOQ", each Date.StartOfQuarter([lpep_pickup_date])),
    TE = Table.FirstN(T5, 1)
in
    TE

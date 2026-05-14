(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    TB = Table.AddColumn(T3, "EOM", each Date.EndOfMonth([lpep_pickup_date])),
    TE = Table.FirstN(TB, 1)
in
    TE

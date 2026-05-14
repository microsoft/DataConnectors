(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    TD = Table.AddColumn(T3, "EOD", each Date.EndOfDay([lpep_pickup_date])),
    TE = Table.FirstN(TD, 1)
in
    TE

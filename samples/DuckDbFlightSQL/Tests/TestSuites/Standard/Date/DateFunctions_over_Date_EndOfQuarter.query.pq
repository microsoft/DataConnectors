(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    TA = Table.AddColumn(T3, "EOQ", each Date.EndOfQuarter([lpep_pickup_date])),
    TE = Table.FirstN(TA, 1)
in
    TE

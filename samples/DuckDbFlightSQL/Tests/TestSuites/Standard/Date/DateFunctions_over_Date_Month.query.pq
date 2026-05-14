(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T5 = Table.AddColumn(T3, "M", each Date.Month([lpep_pickup_date])),
    TA = Table.FirstN(T5, 1)
in
    TA

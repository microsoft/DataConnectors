(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T7 = Table.AddColumn(T3, "QOY", each Date.QuarterOfYear([lpep_pickup_date])),
    TA = Table.FirstN(T7, 1)
in
    TA

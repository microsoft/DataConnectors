(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T8 = Table.AddColumn(T3, "WOY", each Date.WeekOfYear([lpep_dropoff_datetime])),
    TA = Table.FirstN(T8, 1)
in
    TA
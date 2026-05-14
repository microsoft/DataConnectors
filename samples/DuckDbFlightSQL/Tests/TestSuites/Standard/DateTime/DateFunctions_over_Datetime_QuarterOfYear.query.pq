(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T7 = Table.AddColumn(T3, "QOY", each Date.QuarterOfYear([lpep_dropoff_datetime])),
    TA = Table.FirstN(T7, 1)
in
    TA
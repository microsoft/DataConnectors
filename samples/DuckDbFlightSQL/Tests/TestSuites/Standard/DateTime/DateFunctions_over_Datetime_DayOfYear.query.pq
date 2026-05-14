(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T9 = Table.AddColumn(T3, "DOY", each Date.DayOfYear([lpep_dropoff_datetime])),
    TA = Table.FirstN(T9, 1)
in
    TA
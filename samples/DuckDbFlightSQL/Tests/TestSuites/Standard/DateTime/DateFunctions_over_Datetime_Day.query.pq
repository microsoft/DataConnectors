(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T6 = Table.AddColumn(T3, "D", each Date.Day([lpep_dropoff_datetime])),
    TA = Table.FirstN(T6, 1)
in
    TA
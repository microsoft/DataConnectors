(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T5 = Table.AddColumn(T3, "M", each Date.Month([lpep_dropoff_datetime])),
    TA = Table.FirstN(T5, 1)
in
    TA
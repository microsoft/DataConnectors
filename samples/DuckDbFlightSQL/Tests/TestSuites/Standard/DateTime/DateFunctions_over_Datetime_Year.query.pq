(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "Y", each Date.Year([lpep_dropoff_datetime])),
    TA = Table.FirstN(T4, 1)
in
    TA
(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "Y", each Date.Year([lpep_pickup_date])),
    TA = Table.FirstN(T4, 1)
in
    TA

(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_date_table], {"RecordID","lpep_pickup_date"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T9 = Table.AddColumn(T3, "DOY", each Date.DayOfYear([lpep_pickup_date])),
    TA = Table.FirstN(T9, 1)
in
    TA

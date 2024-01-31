(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_pickup_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "Y", each Date.Year([lpep_pickup_datetime])),
    T5 = Table.AddColumn(T4, "M", each Date.Month([lpep_pickup_datetime])),
    T6 = Table.AddColumn(T5, "D", each Date.Day([lpep_pickup_datetime])),
    T7 = Table.AddColumn(T6, "QOY", each Date.QuarterOfYear([lpep_pickup_datetime])),
    T8 = Table.AddColumn(T7, "WOY", each Date.WeekOfYear([lpep_pickup_datetime])),
    T9 = Table.AddColumn(T8, "DOY", each Date.DayOfYear([lpep_pickup_datetime])),
    TA = Table.FirstN(T9, 4)
in
    TA
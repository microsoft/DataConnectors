(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "Y", each Date.Year([lpep_dropoff_datetime])),
    T5 = Table.AddColumn(T4, "M", each Date.Month([lpep_dropoff_datetime])),
    T6 = Table.AddColumn(T5, "D", each Date.Day([lpep_dropoff_datetime])),
    T7 = Table.AddColumn(T6, "QOY", each Date.QuarterOfYear([lpep_dropoff_datetime])),
    T8 = Table.AddColumn(T7, "WOY", each Date.WeekOfYear([lpep_dropoff_datetime])),
    T9 = Table.AddColumn(T8, "DOY", each Date.DayOfYear([lpep_dropoff_datetime])),
    TA = Table.FirstN(T9, 4)
in
    TA
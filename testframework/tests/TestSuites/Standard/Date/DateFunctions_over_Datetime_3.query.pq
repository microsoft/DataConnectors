(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "Y+1", each DateTime.ToText(Date.AddYears([lpep_dropoff_datetime], 1))),
    T5 = Table.AddColumn(T4, "Q+1", each DateTime.ToText(Date.AddQuarters([lpep_dropoff_datetime], 1))),
    T6 = Table.AddColumn(T5, "M+1", each DateTime.ToText(Date.AddMonths([lpep_dropoff_datetime], 1))),
    T7 = Table.AddColumn(T6, "W+1", each DateTime.ToText(Date.AddWeeks([lpep_dropoff_datetime], 1))),
    T8 = Table.AddColumn(T7, "D+1", each DateTime.ToText(Date.AddDays([lpep_dropoff_datetime], 1))),
    T9 = Table.FirstN(T8, 4)
in
    T9
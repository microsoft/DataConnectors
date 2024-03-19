(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_pickup_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "SOY", each DateTime.ToText(Date.StartOfYear([lpep_pickup_datetime]))),
    T5 = Table.AddColumn(T4, "SOQ", each DateTime.ToText(Date.StartOfQuarter([lpep_pickup_datetime]))),
    T6 = Table.AddColumn(T5, "SOM", each DateTime.ToText(Date.StartOfMonth([lpep_pickup_datetime]))),
    T7 = Table.AddColumn(T6, "SOW", each DateTime.ToText(Date.StartOfWeek([lpep_pickup_datetime]))),
    T8 = Table.AddColumn(T7, "SOD", each DateTime.ToText(Date.StartOfDay([lpep_pickup_datetime]))),
    T9 = Table.AddColumn(T8, "EOY", each DateTime.ToText(Date.EndOfYear([lpep_pickup_datetime]))),
    TA = Table.AddColumn(T9, "EOQ", each DateTime.ToText(Date.EndOfQuarter([lpep_pickup_datetime]))),
    TB = Table.AddColumn(TA, "EOM", each DateTime.ToText(DateTime.From(Date.EndOfMonth([lpep_pickup_datetime])))),
    TC = Table.AddColumn(TB, "EOW", each DateTime.ToText(Date.EndOfWeek([lpep_pickup_datetime]))),
    TD = Table.AddColumn(TC, "EOD", each DateTime.ToText(Date.EndOfDay([lpep_pickup_datetime]))),
    TE = Table.FirstN(TD, 4)
in
    TE
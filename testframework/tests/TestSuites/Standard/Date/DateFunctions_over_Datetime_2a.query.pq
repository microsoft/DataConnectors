(parameter) =>
let    
    T2 = Table.SelectColumns(parameter[taxi_table], {"RecordID","lpep_dropoff_datetime"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.AddColumn(T3, "SOY", each Date.StartOfYear([lpep_dropoff_datetime])),
    T5 = Table.AddColumn(T4, "SOQ", each Date.StartOfQuarter([lpep_dropoff_datetime])),
    T6 = Table.AddColumn(T5, "SOM", each Date.StartOfMonth([lpep_dropoff_datetime])),
    T7 = Table.AddColumn(T6, "SOD", each Date.StartOfDay([lpep_dropoff_datetime])),
    T8 = Table.FirstN(T7, 4)
in
    T8
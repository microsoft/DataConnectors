(parameter) => 
let
    T2 = Table.AddColumn(parameter[taxi_table], "soh", each Time.StartOfHour([lpep_pickup_datetime])),
    T_Sorted = Table.Sort(T2, "RecordID"),
    selected = Table.SelectColumns(T_Sorted, {"RecordID", "lpep_pickup_datetime", "soh"}),
    T_FirstN = Table.FirstN(selected, 1)
in
    T_FirstN

(parameter) => 
let
    T2 = Table.AddColumn(parameter[taxi_table], "eoh", each DateTime.ToText(Time.EndOfHour([lpep_pickup_datetime]))),
    T_Sorted = Table.Sort(T2, "RecordID") 
in
    T_Sorted
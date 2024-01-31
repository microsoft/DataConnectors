(parameter) => 
let
    T_Sorted = Table.Sort(parameter[taxi_table], "RecordID") ,
    T2 = Table.AddColumn(T_Sorted, "second", each Time.Second([lpep_pickup_datetime])),
    T3 = Table.SelectColumns(T2, {"lpep_pickup_datetime", "second"})
in
    T3

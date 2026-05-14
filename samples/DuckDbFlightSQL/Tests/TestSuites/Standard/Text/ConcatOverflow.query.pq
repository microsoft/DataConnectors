(parameter) => 
let
    Sorted = Table.Sort(parameter[zone_table], {"LocationID"}),
    T1 = Table.AddColumn(Sorted, "CONCAT", each [Zone] & [service_zone]),
    T2 = Table.SelectColumns(T1, {"CONCAT"})
in
    T2
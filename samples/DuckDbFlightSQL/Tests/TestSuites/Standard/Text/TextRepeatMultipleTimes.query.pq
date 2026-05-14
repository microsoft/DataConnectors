(parameter) => 
let
   T2 = Table.Sort(parameter[zone_table], "LocationID"),
   T3 = Table.FirstN(T2, 1),
   TA = Table.SelectColumns(T3,{"Zone"}),
   T4 = Table.AddColumn(TA, "Repeat_MultipleTimes", each Text.Repeat([Zone], 3))
in
   T4
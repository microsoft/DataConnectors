(parameter) => 
let
   T2 = Table.Sort(parameter[zone_table], "LocationID"),
   T3 = Table.FirstN(T2, 1),
   TA = Table.SelectColumns(T3,{"Zone"}),
   T4 = Table.AddColumn(TA, "withZeroLength", each Text.Middle([Zone], 2, 0))
in
   T4
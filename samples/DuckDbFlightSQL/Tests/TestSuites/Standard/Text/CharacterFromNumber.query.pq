(parameter) => 
let
   T2 = Table.Sort(parameter[zone_table], {"LocationID"}),
   T3 = Table.FirstN(T2, 1),
   T4 = Table.AddColumn(T3, "textFromInt", each Character.FromNumber([LocationID]))
in
   T4
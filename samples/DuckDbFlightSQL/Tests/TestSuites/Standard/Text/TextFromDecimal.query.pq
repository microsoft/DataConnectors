(parameter) => 
let
   T2 = Table.Sort(parameter[taxi_table], "total_amount"),
   T3 = Table.FirstN(T2, 1),
   T4 = Table.AddColumn(T3, "textFromInt", each Text.From([VendorID])),
   T5 = Table.AddColumn(T4, "textFromDecimal", each Text.From([total_amount]))
in
   T5

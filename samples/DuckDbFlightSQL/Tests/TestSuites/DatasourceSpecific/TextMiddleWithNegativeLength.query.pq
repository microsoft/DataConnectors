// Excluded from Standard because DuckDB handles negative length differently than test suite expects
// Expected value is an empty string and DuckDB wraps around negative length
(parameter) =>
let
   T2 = Table.Sort(parameter[zone_table], "LocationID"),
   T3 = Table.FirstN(T2, 1),
   TA = Table.SelectColumns(T3,{"Zone"}),
   T4 = Table.AddColumn(TA, "withNegativeLength", each Text.Middle([Zone], 3, -1))
in
   T4
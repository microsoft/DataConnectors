(parameter) =>
let
    Sort = Table.Sort(parameter[zone_table], {"LocationID"}),
    RowCount = Table.RowCount(Sort)
in
    if (RowCount <> 265) then 
      error "Expected 265 rows in the TaxiZoneLookup table but found " & Number.ToText(RowCount) & " rows."
   else
      RowCount
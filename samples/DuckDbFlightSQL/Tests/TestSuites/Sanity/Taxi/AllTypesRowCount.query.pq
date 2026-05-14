(parameter) =>
let
    Sort = Table.Sort(parameter[taxi_table], {"RecordID"}),
    RowCount = Table.RowCount(Sort)
in
   if (RowCount <> 10000) then 
      error "Expected 10000 rows in the NycTaxiGreen table but found " & Number.ToText(RowCount) & " rows."
   else
      RowCount
(parameter) =>
let
    RowCount = Table.RowCount(parameter[taxi_date_table])
in
   if (RowCount <> 10000) then 
      error "Expected 10000 rows in the NycTaxiGreen table but found " & Number.ToText(RowCount) & " rows."
   else
      RowCount
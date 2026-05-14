(parameter) => 
let
    Sorted = Table.Sort(parameter[zone_table], {{(t) => t[service_zone], Order.Ascending}}),
    FirstN = Table.FirstN(Sorted,5),
    SelectColumns = Table.SelectColumns(FirstN, "service_zone")
in
    SelectColumns

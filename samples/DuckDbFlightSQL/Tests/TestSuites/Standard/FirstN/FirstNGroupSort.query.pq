(parameter) => 
let
    Grouped = Table.Group(parameter[zone_table], {"service_zone"}, {}),
    FirstN = Table.FirstN(Grouped,5),
    Sorted = Table.Sort(FirstN, {{(t) => t[service_zone], Order.Ascending}}),
    SelectColumns = Table.SelectColumns(Sorted, "service_zone")
in
    SelectColumns

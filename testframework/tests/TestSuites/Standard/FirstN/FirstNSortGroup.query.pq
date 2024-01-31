(parameter) => 
let
        Grouped = Table.Group(Sorted, {"service_zone"}, {}),
        Sorted = Table.Sort(parameter[zone_table], {{(t) => t[service_zone], Order.Ascending}}),
        FirstN = Table.FirstN(Sorted,3),
        SelectColumns = Table.SelectColumns(FirstN, "service_zone")
    in
        SelectColumns

(parameter) => 
let
    Sorted = Table.Sort(parameter[zone_table], {"LocationID"}),
    Grouped = Table.Group(Sorted, {"service_zone"}, {}),
    FirstN = Table.FirstN(Grouped,3),
    SelectColumns = Table.SelectColumns(Grouped, "service_zone")
in
    SelectColumns
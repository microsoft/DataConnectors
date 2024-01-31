(parameter) =>
let
    Sort = Table.Sort(parameter[zone_table], {"LocationID"})
in
    Sort
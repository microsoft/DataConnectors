(parameter) =>
let
    SelectRows = Table.SelectRows(parameter[zone_table], each [Borough] = "Queens"),
    SelectColumns = Table.SelectColumns(SelectRows, { "Borough", "LocationID" }),
    Sort = Table.Sort(SelectColumns, {"LocationID"}),
    FirstN = Table.FirstN(Sort, 2)
in
    FirstN

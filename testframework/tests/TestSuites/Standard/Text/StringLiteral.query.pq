(parameter) =>
let
    Sort = Table.Sort(parameter[zone_table], {"LocationID"}),
    SelectRows = Table.SelectRows(Sort, each [Zone] = "Westchester Village/Unionport"),
    SelectColumns = Table.SelectColumns(SelectRows, { "Zone" })
in
    SelectColumns
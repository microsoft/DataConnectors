(parameter) =>
let
    AddedColumn = Table.AddColumn(parameter[zone_table], "Startswith", each Text.StartsWith([Zone], "West")),
    SelectRows = Table.SelectRows(AddedColumn, each [Zone] = "Westchester Village/Unionport")
in
    SelectRows
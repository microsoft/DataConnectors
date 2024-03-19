(parameter) =>
let
    AddColumn = Table.AddColumn(parameter[taxi_table], "Column", each [total_amount] + [VendorID]),
    SelectColumns = Table.SelectColumns(AddColumn, { "Column" }),
    GroupedRows = Table.Group(parameter[taxi_table], {}, {{"Column", each Number.Round(List.Sum([total_amount]), 2), type number}})
in
    GroupedRows
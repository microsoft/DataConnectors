(parameter) =>
let
    SelectRows = Table.AddColumn(parameter[taxi_table], "Column", each "#(lf)#(tab)#(0000)"),
    SelectColumns = Table.SelectColumns(SelectRows, { "Column" }),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
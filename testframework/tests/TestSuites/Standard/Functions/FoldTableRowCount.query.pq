(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Row Count", (x) => Table.RowCount(x), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
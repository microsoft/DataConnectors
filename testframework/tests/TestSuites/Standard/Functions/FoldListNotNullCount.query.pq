(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Not Null Count", each List.NonNullCount([RatecodeID]), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
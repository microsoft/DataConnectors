(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Minimum", each List.Min([trip_distance]), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
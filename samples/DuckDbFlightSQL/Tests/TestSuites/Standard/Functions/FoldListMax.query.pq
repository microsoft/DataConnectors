(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Maximum", each List.Max([trip_distance]), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
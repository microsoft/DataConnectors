(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Count", each List.Count([trip_distance]), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Average", each Number.Round(List.Average([trip_distance]), 8), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
(parameter) =>
let
	t = Table.Group(parameter[taxi_table], {}, {{"Standard Deviation", each Number.RoundUp(List.StandardDeviation([fare_amount]),5), type number}})
in
	t
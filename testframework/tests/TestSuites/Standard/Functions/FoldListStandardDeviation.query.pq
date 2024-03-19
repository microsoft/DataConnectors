(parameter) =>
let
	t = Table.Group(parameter[taxi_table], {}, {{"Standard Deviation", each List.StandardDeviation([fare_amount]), type number}})
in
	t
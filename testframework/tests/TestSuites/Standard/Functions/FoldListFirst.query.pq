(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {"PULocationID"}, {{"First", each List.First([trip_distance]), type number}}),
    Sort = Table.Sort(SelectColumns,{"PULocationID", Order.Descending}),
    FirstN = Table.FirstN(Sort, 1)
in
    FirstN
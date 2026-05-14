(parameter) => 
let
    SelectColumns = Table.Group(parameter[taxi_table], {"PULocationID"}, {{"CountDistinct", each List.Count(List.Distinct([trip_distance])), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
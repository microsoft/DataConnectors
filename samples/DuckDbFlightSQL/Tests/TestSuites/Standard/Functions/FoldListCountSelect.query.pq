(parameter) => 
let
    SelectColumns = Table.Group(parameter[taxi_table], {"PULocationID"}, {{"CountSelect", each List.Count(List.Select([trip_distance],each _ <> null)), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
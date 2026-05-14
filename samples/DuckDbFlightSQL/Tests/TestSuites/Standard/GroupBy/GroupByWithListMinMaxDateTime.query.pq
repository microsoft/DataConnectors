(parameter) => 
let
    T1 = parameter[taxi_table],
    T2 = Table.SelectColumns(T1,{"PULocationID","lpep_pickup_datetime"}),
    T3 = Table.Group(T2, {"PULocationID"}, {{"MaxWithDateTime", each List.Max([lpep_pickup_datetime])}, {"MinWithDateTime", each List.Min([lpep_pickup_datetime])}}),
    T4 = Table.Sort(T3,{"PULocationID"})
in
    Table.FirstN(T4,5)
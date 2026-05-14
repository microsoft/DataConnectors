(parameter) => 
let
    Sorted = Table.Sort(parameter[taxi_table], {"lpep_pickup_datetime", Order.Ascending}),
    FirstNRecords = Table.FirstN(Sorted, 10),
    Grouped = Table.Group(FirstNRecords, {"PULocationID"},  {"total_trip_distance", each List.Sum([trip_distance])})
in
    Grouped

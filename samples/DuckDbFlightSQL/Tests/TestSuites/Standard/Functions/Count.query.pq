(parameter) => 
let
    Count = Table.Group(parameter[taxi_table], { "lpep_pickup_datetime" }, { { "Count", each List.Count([lpep_pickup_datetime]) } }),
    First = Count{0}
in
    First
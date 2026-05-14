(parameter) => 
let
    T2 = Table.SelectColumns(parameter[taxi_table],{"lpep_pickup_datetime"}),
    T3 = Table.SelectRows(T2, each [lpep_pickup_datetime] = #datetime(2023, 02, 26, 18, 57, 00))
in
    T3
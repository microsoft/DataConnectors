(parameter) => 
let
    result = Table.SelectRows(parameter[taxi_table], each List.Contains({1},[PULocationID]))
in
    result
(parameter) => 
let
    result = Table.SelectRows(parameter[taxi_table], each List.Contains({1,2,null},[PULocationID]))
in
    result
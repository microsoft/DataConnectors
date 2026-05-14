(parameter) => 
let
    result = Table.SelectRows(parameter[taxi_table], each List.Contains({null,0},[PULocationID]))
in
    result
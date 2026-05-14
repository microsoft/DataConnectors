(parameter) => 
let
    result = Table.SelectRows(parameter[taxi_table], each List.Contains({null},[PULocationID]))
in
    result
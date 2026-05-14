(parameter) =>
let
    Sort = Table.Sort(parameter[taxi_date_table], {"RecordID"})
in
    Sort
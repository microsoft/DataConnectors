(parameter) =>
let
    Sort = Table.Sort(parameter[taxi_table], {"RecordID"})
in
    Table.Buffer(Table.FirstN(Sort, 1))
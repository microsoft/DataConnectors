(parameter) =>
let
    Sort = Table.Sort(parameter[taxi_table], {"RecordID"}),
    FirstN = Table.FirstN(Sort, 1)
in
    FirstN
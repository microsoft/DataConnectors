(parameter) =>
let
    TBL = Table.AddColumn(parameter[taxi_table], "Custom", each Int64.From([store_and_fwd_flag])),
    Sort = Table.Sort(TBL, {"RecordID"}),
    FirstN = Table.FirstN(Sort, 5)
in
    FirstN


    
(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    T2 = Table.SelectColumns(Sorted, {"PULocationID","lpep_pickup_datetime"}),
    T3 = Table.Sort(T2, {"PULocationID"}),
    T4 = Table.AddColumn(T3, "Diff1", each [lpep_pickup_datetime] - #datetime(1999,1,5,0,0,0)),
    T5 = Table.AddColumn(T4, "Diff2", each [lpep_pickup_datetime] - #datetime(2007,2,6,0,0,0)),
    T6 = Table.AddColumn(T5, "Diff3", each [lpep_pickup_datetime] - #datetime(2007,9,5,0,0,0)),
    TA = Table.FirstN(T6, 4)
in
    TA
(parameter) => 
let
    Sorted = Table.Sort(parameter[taxi_table], {{"PULocationID", Order.Ascending}, {"RecordID", Order.Ascending}}),
    SelectColumns = Table.Group(Sorted, {"PULocationID"}, {{"First", each List.First([trip_distance]), type number}}, GroupKind.Local),
    Sort = Table.Sort(SelectColumns,{"PULocationID", Order.Descending}),
    FirstN = Table.FirstN(Sort, 1)
in
    FirstN

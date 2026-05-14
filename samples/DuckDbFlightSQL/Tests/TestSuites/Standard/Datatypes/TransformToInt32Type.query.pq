(parameter) =>
let
    TBL = Table.TransformColumnTypes(parameter[taxi_table],{{"trip_distance", Int64.Type}}),
    Sorted = Table.Sort(TBL, {"RecordID", Order.Descending}),
    Custom = Table.SelectColumns(Sorted, {"trip_distance"}),
    FirstN = Table.FirstN(Custom, 1)
in
    Table.Buffer(FirstN)
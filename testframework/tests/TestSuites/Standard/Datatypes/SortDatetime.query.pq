(parameter) =>
let
    SelectColumns = Table.SelectColumns(parameter[taxi_table], { "lpep_dropoff_datetime" }),
    Sort = Table.Sort(SelectColumns, {{(t1008) => if t1008[lpep_dropoff_datetime] <> null then t1008[lpep_dropoff_datetime] else DateTime.From(- 2), Order.Ascending}, {(t1009) => if t1009[lpep_dropoff_datetime] = null then 0 else 1, Order.Ascending}})
in
    Sort
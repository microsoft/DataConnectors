(parameter) =>
let
    T1 = Table.SelectRows(parameter[taxi_date_table], each ([RecordID] = 47531) and ([lpep_pickup_date] = #date(2023, 2, 23))),
    T2 = Table.SelectColumns(T1,{"RecordID", "lpep_pickup_date", "lpep_dropoff_date"}),
    T3 = Table.Sort(T2, {"RecordID"})
in
    T3
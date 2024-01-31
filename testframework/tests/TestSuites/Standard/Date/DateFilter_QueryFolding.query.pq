(parameter) =>
let
    T1 = Table.SelectRows(parameter[taxi_table], each ([PULocationID] = 75 or [DOLocationID] = 170) and (DateTime.Date([lpep_pickup_datetime]) = #date(2023, 2, 23))),
    T2 = Table.SelectColumns(T1,{"RecordID", "lpep_pickup_datetime", "lpep_dropoff_datetime", "PULocationID", "DOLocationID"}),
    T3 = Table.Sort(T2, {"RecordID"})
in
    T3
(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
    t1070 = Table.RenameColumns(taxi_table, {{"VendorID", "t1.VendorID"}, {"trip_distance", "t1.trip_distance"}, {"fare_amount", "t1.fare_amount"}, {"PULocationID", "t1.PULocationID"}, {"payment_type", "t1.payment_type"}}),
    t1071 = Table.RenameColumns(zone_table, {{"LocationID", "t0.LocationID"}, {"Borough", "t0.Borough"}, {"Zone", "t0.Zone"}}),
    t1379 = Table.Join(t1070, {"t1.PULocationID"}, t1071, {"t0.LocationID"}, JoinKind.LeftOuter, null),
    t1136 = Table.SelectRows(t1379, (t1135) => (List.Contains({"Bronx"}, t1135[t0.Borough]) or t1135[t0.Borough] = null) and (List.Contains({1}, Int64.From(t1135[t1.VendorID])) or t1135[t1.VendorID] = null)),
    t1142 = Table.Group(t1136, {"t1.trip_distance", "t1.fare_amount", "t1.payment_type"}, {}),
    t1146 = Table.Sort(t1142, {{(t1143) => t1143[t1.trip_distance], Order.Ascending}, {(t1144) => t1144[t1.payment_type], Order.Ascending}, {(t1145) => t1145[t1.fare_amount], Order.Ascending}}),
    t1147 = Table.SelectColumns(t1146, {"t1.trip_distance", "t1.fare_amount", "t1.payment_type"}),
    FirstN = Table.FirstN(t1147, 5)
in
    FirstN

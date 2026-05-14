(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
    t1070 = Table.RenameColumns(taxi_table, {{"VendorID", "t1.VendorID"}, {"trip_distance", "t1.trip_distance"}, {"fare_amount", "t1.fare_amount"}, {"PULocationID", "t1.PULocationID"}, {"payment_type", "t1.payment_type"}}),
    t1071 = Table.RenameColumns(zone_table, {{"LocationID", "t0.LocationID"}, {"Borough", "t0.Borough"}, {"Zone", "t0.Zone"}}),
    t1072 = Table.Join(t1070, {"t1.PULocationID"}, t1071, {"t0.LocationID"}, JoinKind.LeftOuter, null),
    t1075 = Table.SelectRows(t1072, (t1074) => Value.Equals(t1074[t0.Borough], "Bronx") and Value.NullableEquals(Int64.From(t1074[t1.VendorID]), 1)),
    t1081 = Table.Group(t1075, {"t1.trip_distance", "t1.fare_amount", "t1.payment_type"}, {}),
    t1085 = Table.Sort(t1081, {{(t1082) => t1082[t1.trip_distance], Order.Ascending}, {(t1083) => t1083[t1.payment_type], Order.Ascending}, {(t1084) => t1084[t1.fare_amount], Order.Ascending}}),
    t1086 = Table.SelectColumns(t1085, {"t1.trip_distance", "t1.fare_amount", "t1.payment_type"}),
    FirstN = Table.FirstN(t1086, 5)
in
    FirstN
(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
    t1129 = Table.RenameColumns(taxi_table, {{"VendorID", "t1.VendorID"}, {"trip_distance", "t1.trip_distance"}, {"fare_amount", "t1.fare_amount"}, {"PULocationID", "t1.PULocationID"}, {"payment_type", "t1.payment_type"}}),
    t1130 = Table.RenameColumns(zone_table, {{"LocationID", "t0.LocationID"}, {"Borough", "t0.Borough"}, {"Zone", "t0.Zone"}}),
    t1131 = Table.Join(t1129, {"t1.PULocationID"}, t1130, {"t0.LocationID"}, JoinKind.LeftOuter, null),
    t1134 = Table.SelectRows(t1131, (t1133) => Value.Equals(t1133[t0.Borough], "Bronx") and Value.NullableEquals(Int64.From(t1133[t1.VendorID]), 1)),
    t1139 = Table.Group(t1134, {"t1.payment_type"}, {{"a0", (t1135) => List.Count(List.Select(t1135[t1.VendorID], each _ <> null))}}),
    t1140 = Table.SelectColumns(t1139, {"t1.payment_type", "a0"}),
    FirstN = Table.FirstN(t1140, 5)
in
    FirstN
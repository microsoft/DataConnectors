(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
	tc = Table.PrefixColumns(taxi_table, "t0"),
    tp = Table.PrefixColumns(zone_table, "t1"),
    joined = Table.Join(tp, {"t1.LocationID"}, tc, {"t0.PULocationID"}, JoinKind.LeftOuter, null),
    added = Table.AddColumn(joined, "t1.LocationID_copy", (temp1) => temp1[t1.LocationID]),
    selected = Table.SelectColumns(added, {"t1.LocationID", "t1.LocationID_copy"}),
    sorted = Table.Sort(selected, {"t1.LocationID"}),
    FirstN = Table.FirstN(sorted, 5)
in
    FirstN
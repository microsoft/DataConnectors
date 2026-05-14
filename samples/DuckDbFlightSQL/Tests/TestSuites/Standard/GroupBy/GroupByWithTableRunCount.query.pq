(parameter) => 
let 
    t1360 = Table.PrefixColumns(parameter[zone_table], "t0"),       
    t1366 = Table.Group(t1360, {"t0.Zone"}, {{"c2", (t1361) => List.First(t1361[t0.Zone])}, {"a0", (t1362) => Table.RowCount(t1362)}}),        
    t1367 = Table.SelectColumns(t1366, {"c2", "a0"})  
in
    t1367
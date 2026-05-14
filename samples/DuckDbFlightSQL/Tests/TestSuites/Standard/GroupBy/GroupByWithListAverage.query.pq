(parameter) => 
let
    T1 = parameter[zone_table],
    T2 = Table.SelectColumns(T1,{"Borough","LocationID"}),
    T3 = Table.Group(T2, {"Borough"}, {{"Grouped", each List.Average([LocationID],Precision.Decimal), type number}}),
    T4 = Table.TransformColumns(T3,{{"Grouped", each Number.Round(_, 6)}}),
    T5 = Table.Sort(T4,{{"Borough", Order.Ascending}})
in
    Table.FirstN(T5,1)
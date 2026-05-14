(parameter) => 
let
    T1 = parameter[zone_table],
    T2 = Table.SelectColumns(T1,{"Borough","Zone","LocationID"}),
    T3 = Table.Group(T2, {"Borough"}, {{"MaxWithString", each List.Max([Zone])},{"MinWithString", each List.Min([Zone])},
        {"MaxWithInteger", each List.Max([LocationID])},{"MinWithInteger", each List.Min([LocationID])}}),
    T4 = Table.Sort(T3,{"Borough"})
in
    Table.FirstN(T4,5)
(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T18 = Table.AddColumn(T1,"ValueReplaceType", each Value.ReplaceType([passenger_count],type number)),
    Result = Table.FirstN(T18,1)
in
    Result

(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T9 = Table.AddColumn(T1,"SubtractDoublePrecision", each Value.Subtract([passenger_count],[total_amount],Precision.Double)),
    Result = Table.FirstN(T9,1)
in
    Result

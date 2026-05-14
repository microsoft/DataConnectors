(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T2 = Table.AddColumn(T1,"MultiplyDefault",each Value.Multiply([passenger_count],[total_amount])),
    Result = Table.FirstN(T2,1)
in
    Result

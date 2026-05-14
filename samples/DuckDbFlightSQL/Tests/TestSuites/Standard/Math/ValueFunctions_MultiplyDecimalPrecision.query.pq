(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T4 = Table.AddColumn(T1,"MultiplyDecimalPrecision", each Value.Multiply([passenger_count],[total_amount],Precision.Decimal)),
    Result = Table.FirstN(T4,1)
in
    Result

(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T12 = Table.AddColumn(T1,"DivideDoublePrecision", each Number.RoundDown(Value.Divide([passenger_count],[total_amount],Precision.Double),5)),
    Result = Table.FirstN(T12,1)
in
    Result

(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T16 = Table.AddColumn(T1,"CompareDecimalPrecision", each Value.Compare([passenger_count],[total_amount],Precision.Decimal)),
    Result = Table.FirstN(T16,1)
in
    Result

(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T17 = Table.AddColumn(T1,"ValueAs", each Value.As([passenger_count],type any)),
    Result = Table.FirstN(T17,1)
in
    Result

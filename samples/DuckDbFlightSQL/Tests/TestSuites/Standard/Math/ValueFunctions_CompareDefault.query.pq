(parameter) =>
let
    T = Table.Sort(parameter[taxi_table],{{"total_amount", Order.Descending}}),
    T0 = Table.FirstN(T,5),
    T1 = Table.SelectColumns(T0,{"passenger_count","total_amount"}),
    T14 = Table.AddColumn(T1,"CompareDefault",each Value.Compare([passenger_count],[total_amount])),
    Result = Table.FirstN(T14,1)
in
    Result

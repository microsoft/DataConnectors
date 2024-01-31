(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"total_amount","payment_type"}),
    T3 = Table.AddColumn(T2, "PaymentTypeIsEmpty", each Value.NullableEquals([payment_type],4)),
    T4 = Table.Sort(T3, "total_amount"),
    T5 = Table.FirstN(T4,5)
in
    T5
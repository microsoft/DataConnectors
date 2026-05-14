(parameter) =>
let
    T = parameter[taxi_summary_view],
    T1 = Table.FirstN(T, 1)
in
    T1
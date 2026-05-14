(parameter) =>
let
    T = parameter[nested_types_table],
    T1 = Table.FirstN(T, 1)
in
    T1
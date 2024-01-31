(parameter) =>
let
    GetResult = (transform) =>
        let
            Transformed = transform(parameter[taxi_table]),
            RowCount = Table.RowCount(Transformed)
        in
            RowCount
in
    [
        NoSkipTake = GetResult((table) => table),
        FirstN = GetResult((table) => Table.FirstN(table, 1)),
        Skip = GetResult((table) => Table.Skip(table, 2199)),
        FirstNSkip = GetResult((table) => Table.FirstN(Table.Skip(table, 2198), 1))
    ]
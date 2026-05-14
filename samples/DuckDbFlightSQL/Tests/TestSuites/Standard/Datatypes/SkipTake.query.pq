(parameter) =>
let
    GetResult = (transform) =>
        let
            Sort = Table.Sort(parameter[zone_table], {"LocationID"}),
            Transformed = transform(Sort)
        in
            Transformed
in
    [
        FirstN = GetResult((table) => Table.FirstN(table, 1)),
        Skip = GetResult((table) => Table.Skip(table, 264)),
        FirstNSkip = GetResult((table) => Table.FirstN(Table.Skip(table, 200), 1)),
        NoSkipTake = GetResult((table) => table)
    ]
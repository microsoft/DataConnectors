(parameter) =>
    let
        Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
        AddColumns = Table.AddColumn(Sorted, "ATAN2", each Number.RoundDown(Number.Atan2([fare_amount], 1), 5)),
        SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
        SelectColumns = Table.SelectColumns(SelectRows, {"ATAN2"}),
        FirstN = Table.FirstN(SelectColumns, 1)
    in
        FirstN

(parameter) =>
let
    Columns = [
        EXP = each Number.Exp([fare_amount])
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "EXP", Columns[EXP]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"EXP"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

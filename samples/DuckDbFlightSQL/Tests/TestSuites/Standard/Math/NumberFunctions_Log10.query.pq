(parameter) =>
let
    Columns = [
        LOG10 = each Number.Round(Number.Log10([PULocationID]), 12)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "LOG10", Columns[LOG10]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"LOG10"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

(parameter) =>
let
    Columns = [
        LOG = each Number.RoundDown(Number.Log([PULocationID]),5)
    ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = Table.AddColumn(Sorted, "LOG", Columns[LOG]),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, {"LOG"}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

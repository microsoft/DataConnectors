(parameter) =>
let
    EnsureLocal = Table.StopFolding(parameter[taxi_table]),
    Schema = Table.Schema(EnsureLocal),
    SelectColumns = Table.SelectColumns(Schema,{"Name", "Kind", "IsNullable"}),
    Sort = Table.Sort(SelectColumns,{{"Name", Order.Ascending}})
in
    Sort

(parameter) =>
let
    Sort = Table.Sort(parameter[zone_table], {"LocationID"}),
    Columns = [
        Contains = each Text.Contains([Zone], "ton") ,
        StartsWith = each Text.StartsWith([Zone], "Was"),
        EndsWith = each Text.EndsWith([Zone], "th")
        
    ],
    SelectRows = List.Accumulate(Record.FieldNames(Columns), Sort,
        (state, current) => Table.SelectRows(state, Record.Field(Columns, current))),
    SelectColumns = Table.SelectColumns(SelectRows, { "Zone" }),
    Buffer = Table.Buffer(SelectColumns)
in
    Buffer
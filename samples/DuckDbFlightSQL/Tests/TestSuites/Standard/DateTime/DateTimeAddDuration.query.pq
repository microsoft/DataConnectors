(parameter) => 
let
    Columns = [
        AddDay = each [lpep_pickup_datetime] + #duration(1,0,0,0),
        AddHour = each [lpep_pickup_datetime] + #duration(0,1,0,0),
        AddMinute = each [lpep_pickup_datetime] + #duration(0,0,1,0),
        AddSecond = each [lpep_pickup_datetime] + #duration(0,0,0,1),
        AddAll = each [lpep_pickup_datetime] + #duration(1,1,1,1.25),
        Subtract = each [lpep_pickup_datetime] - #duration(1,1,1,1.25)
    ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), parameter[taxi_table],
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectedColumns = Table.SelectColumns(AddColumns, {"RecordID", "lpep_pickup_datetime", "AddDay", "AddHour", "AddMinute", "AddSecond", "AddAll", "Subtract"}),
    Sorted = Table.Sort(SelectedColumns,{"RecordID", Order.Descending}),
    FirstN = Table.FirstN(Sorted,5)
in
    Table.Buffer(FirstN)
 (parameter) =>
 let
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    Columns = [            
        AddDays = each Date.AddDays([lpep_pickup_datetime], 2),
        SubDays = each Date.AddDays([lpep_pickup_datetime], -2),
        AddYears = each Date.AddYears([lpep_pickup_datetime], 2),
        SubYears = each Date.AddYears([lpep_pickup_datetime], -2),
        AddMonths = each Date.AddMonths([lpep_pickup_datetime], 2),
        SubMonths = each Date.AddMonths([lpep_pickup_datetime], -2),
        AddQuarter = each Date.AddQuarters([lpep_pickup_datetime], 2),
        SubQuarter = each Date.AddQuarters([lpep_pickup_datetime], -2),
        AddWeeks = each Date.AddWeeks([lpep_pickup_datetime], 2),
        SubWeeks = each Date.AddWeeks([lpep_pickup_datetime], -2)
    ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 75),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

// To Do: This test fails for BigQuery as the time is ignored for date operations.
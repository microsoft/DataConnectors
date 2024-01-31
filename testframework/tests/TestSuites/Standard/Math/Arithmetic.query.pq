(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table],{"fare_amount", Order.Descending}),
    Columns = [            
        AdditionInteger = each[PULocationID] + 90, 
        SubtractionInteger = each [PULocationID] - 90,
        MultiplicationInteger = each [PULocationID] * 90,
        DivisionInteger = each Number.Round(([PULocationID] / 90), 8),
        AdditionFloat = each[fare_amount] + 90,
        SubtractionFloat = each [fare_amount] - 90,
        MultiplicationFloat = each Number.Round([fare_amount] * 90.0, 8),
        DivisionFloat = each Number.Round(([fare_amount] / 90.0), 8)
    ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 193),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1) 
in
    FirstN
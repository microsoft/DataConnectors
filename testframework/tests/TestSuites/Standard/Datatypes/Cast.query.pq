(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    Columns = [
                TimestampToDateCast = each Date.From([lpep_pickup_datetime]),
                TimestampToStringCast = each Text.From([lpep_dropoff_datetime],"en-US"),
                FloatToIntegerCast =    each Int64.From([trip_distance]),
                FloatToStringCast =     each Text.From(Number.Round([fare_amount], 2)),
                IntegerToFloatCast =    each Double.From([PULocationID]),
                IntegerToStringCast =   each Text.From([passenger_count]),
                BooleanToStringCast =   each Text.From([store_and_fwd_flag])
            ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 75),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
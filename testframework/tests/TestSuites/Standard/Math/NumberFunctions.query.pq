(parameter) =>
let
    Columns = [
            ABS = each Number.Abs([fare_amount]) ,
            ACOS = each Number.Acos([fare_amount] / [fare_amount]),
            ASIN = each Number.Asin([fare_amount] / [fare_amount]),
            ATAN = each Number.Atan([fare_amount]),
            CEILING = each Number.RoundUp([fare_amount]),
            COS = each Number.Cos([fare_amount]),
            EXP = each Number.Exp([fare_amount]),
            FLOOR = each Number.RoundDown([fare_amount]),
            LOG = each Number.Log([PULocationID]),
            LOG10 = each Number.Round(Number.Log10([PULocationID]), 12),
            POWER = each Number.Power([fare_amount] / [fare_amount], 3),
            ROUND = each Number.Round([fare_amount]),
            ROUNDDIGITS = each Number.Round([fare_amount], 1),
            SIGN = each Number.Sign([fare_amount]),
            SQRT = each Number.Sqrt([fare_amount]),
            TAN = each Number.Tan([fare_amount])
        ],
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULocationID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN
(parameter) =>
let
    T1 = Table.AddColumn(parameter[taxi_table], "EOD", each Date.EndOfDay([lpep_dropoff_datetime])),
    T2 = Table.SelectColumns(T1, {"RecordID","lpep_dropoff_datetime","EOD"}),
    T3 = Table.Sort(T2, {"RecordID"}),
    T4 = Table.FirstN(T3, 1),
    T5 = Table.TransformColumns(T4, {"EOD", each let d = _ in #datetime(Date.Year(d), Date.Month(d), Date.Day(d), Time.Hour(d), Time.Minute(d), Number.RoundDown(Time.Second(d)))})
in
    Table.Buffer(T5)

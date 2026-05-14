(parameter) =>
let
    ColumnNames = { "VendorID", "lpep_pickup_datetime", "store_and_fwd_flag", "trip_distance" },
    Tests = List.Accumulate(ColumnNames, [], (state, current) => 
        let 
            Result =
                let
                    Sort = Table.Sort(parameter[taxi_table], current),
                    RowCount = Table.RowCount(Sort)
                in
                    RowCount,
            AddField =  Record.AddField(state, current, Result)
        in
            AddField)
in
    Tests
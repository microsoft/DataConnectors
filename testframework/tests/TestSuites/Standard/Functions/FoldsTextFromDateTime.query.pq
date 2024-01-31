(parameter) => 
let
    Sorted = Table.Sort(parameter[taxi_table], {"RecordID"}),
    TablePickupDateTimeCast = Table.AddColumn(Sorted, "casted_lpep_pickup_datetime", each Text.From([lpep_pickup_datetime],"en-US")),
    TableDropoffDateTimeCast = Table.AddColumn(TablePickupDateTimeCast, "casted_lpep_dropoff_datetime", each Text.From([lpep_dropoff_datetime],"en-US")),
    TableSelect = Table.SelectColumns(
        TableDropoffDateTimeCast,
        {
            "lpep_pickup_datetime",
            "lpep_dropoff_datetime",
            "casted_lpep_pickup_datetime",
            "casted_lpep_dropoff_datetime"
        }
    ),
    FirstN = Table.FirstN(TableSelect, 1)
in
    FirstN
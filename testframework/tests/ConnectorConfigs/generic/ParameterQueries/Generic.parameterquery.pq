Replace with the M query to connect to your data source and retrieve the NycTaxiGreen & TaxiZoneLookup Table

// Example:
// let
//     Source = Sql.Database("your_server_name", "your_dabase_name"),
//     NycTaxiGreen_Table = Source{[Schema="your_schema_name",Item="NycTaxiGreen"]}[Data],
//     TaxiZoneLookup_Table =  Source{[Schema="your_schema_name",Item="TaxiZoneLookup"]}[Data]
// in
//     [taxi_table = NycTaxiGreen_Table, zone_table = TaxiZoneLookup_Table]
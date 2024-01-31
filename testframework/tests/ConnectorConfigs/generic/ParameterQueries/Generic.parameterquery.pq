Replace with the M query to connect to your data source and retrieve the NycTaxiGreen & TaxiZoneLookup Table

// Example:
// let
//     Source = GoogleBigQuery.Database(),
//     Database = Source{[Name="msft-pbi",Kind="Database"]}[Data],
//     PQTestData_Schema = Database{[Name="PQTestData",Kind="Schema"]}[Data],
//     NycTaxiGreen_Table = PQTestData_Schema{[Name="NycTaxiGreen",Kind="Table"]}[Data],
//     TaxiZoneLookup_Table = PQTestData_Schema{[Name="TaxiZoneLookup",Kind="Table"]}[Data]
// in
//     [taxi_table = NycTaxiGreen_Table, zone_table = TaxiZoneLookup_Table]
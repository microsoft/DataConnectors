let
    Source = GoogleBigQuery.Database(),
    Database = Source{[Name="msft-pbi",Kind="Database"]}[Data],
    Taxi_Table = Value.NativeQuery(Database, "select * from msft-pbi.PQTestData.NycTaxiGreen", null, [EnableFolding=true]),
    Zone_Table = Value.NativeQuery(Database, "select * from msft-pbi.PQTestData.TaxiZoneLookup", null, [EnableFolding=true])
in
    [taxi_table = Taxi_Table, zone_table = Zone_Table]
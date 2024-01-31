let
    Taxi_Table = Value.NativeQuery(Snowflake.Databases("POWERBI.snowflakecomputing.com", "DEMO_WH", [CommandTimeout=10000]){[Name="NYCTAXIDB"]}[Data], "select * from PUBLIC.NYCTAXIDATA", null, [EnableFolding=true]),
    Zone_Table = Value.NativeQuery(Snowflake.Databases("POWERBI.snowflakecomputing.com", "DEMO_WH", [CommandTimeout=10000]){[Name="NYCTAXIDB"]}[Data], "select * from PUBLIC.TAXIZONELOOKUP", null, [EnableFolding=true])
in
    [taxi_table = Taxi_Table, zone_table = Zone_Table]
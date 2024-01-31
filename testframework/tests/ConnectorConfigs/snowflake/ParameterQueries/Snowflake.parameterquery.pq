let
    Source = Snowflake.Databases("POWERBI.snowflakecomputing.com", "DEMO_WH", [CommandTimeout=10000]),
    Database = Source{[Name="NYCTAXIDB",Kind="Database"]}[Data],
    Schema = Database{[Name="PUBLIC",Kind="Schema"]}[Data],
    Taxi_Table = Schema{[Name="NYCTAXIDATA",Kind="Table"]}[Data],
    Zone_Table = Schema{[Name="TAXIZONELOOKUP",Kind="Table"]}[Data]
in 
    [taxi_table = Taxi_Table, zone_table = Zone_Table]
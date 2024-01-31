let
    Source = ApacheSpark.Tables("apachesparkstandard.westus.cloudapp.azure.com:10016", 0),
    Taxi_Table = Source{[Name="nyctaxidata"]}[Data],
    Zone_Table = Source{[Name="taxizonelookup"]}[Data]
in
    [taxi_table = Taxi_Table, zone_table = Zone_Table]
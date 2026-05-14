let
    Source = DuckDb.Contents("localhost:31337", "Disabled", null),
    database = Source{[Name = "TPC-H-small", Kind = "Database"]}[Data],
    main_Schema = database{[Name = "main", Kind = "Schema"]}[Data],
    nyctaxidata_Table = main_Schema{[Name = "NycTaxiData", Kind = "Table"]}[Data]
in
    nyctaxidata_Table
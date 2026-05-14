let
    Source = DuckDb.Contents("localhost:31337", "Disabled", null),
    database = Source{[Name = "TPC-H-small", Kind = "Database"]}[Data],
    main_Schema = database{[Name = "main", Kind = "Schema"]}[Data],
    misc_table = main_Schema{[Name = "misc_table", Kind = "Table"]}[Data],
    nyctaxidata_Table = main_Schema{[Name = "NycTaxiData", Kind = "Table"]}[Data],
    taxizonelookup_Table = main_Schema{[Name = "TaxiZoneLookup", Kind = "Table"]}[Data],
    taxidate_Table = main_Schema{[Name = "NycTaxiDateData", Kind = "Table"]}[Data],
    textSamples_Table = main_Schema{[Name = "TEXT_SAMPLES", Kind = "Table"]}[Data],
    extendedTypes_Table = main_Schema{[Name = "ExtendedTypes", Kind = "Table"]}[Data],
    nestedTypes_Table = main_Schema{[Name = "NestedTypes", Kind = "Table"]}[Data],
    nycTaxiSummary_View = main_Schema{[Name = "NycTaxiSummary", Kind = "View"]}[Data]
in
    [zone_table = taxizonelookup_Table, taxi_table = nyctaxidata_Table, taxi_date_table = taxidate_Table, text_samples_table = textSamples_Table, misc_table = misc_table, extended_types_table = extendedTypes_Table, nested_types_table = nestedTypes_Table, taxi_summary_view = nycTaxiSummary_View]
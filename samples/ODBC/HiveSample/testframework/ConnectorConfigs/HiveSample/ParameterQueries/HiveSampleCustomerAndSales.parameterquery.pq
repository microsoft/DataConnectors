// Parameter query: retrieves both the customer and sales_fact tables as a record.
// Used by join tests that require two related tables from the same data source.
// Update host and port to match your Hive LLAP instance before running tests.
let
    Source      = HiveSample.Contents("127.0.0.1", 10500),
    Database    = Source{[Name = "HIVE",     Kind = "Database"]}[Data],
    Schema      = Database{[Name = "foodmart", Kind = "Schema"]}[Data],
    Customer    = Schema{[Name = "customer",   Kind = "Table"]}[Data],
    Sales       = Schema{[Name = "sales_fact", Kind = "Table"]}[Data]
in
    [CustomerTable = Customer, SalesTable = Sales]

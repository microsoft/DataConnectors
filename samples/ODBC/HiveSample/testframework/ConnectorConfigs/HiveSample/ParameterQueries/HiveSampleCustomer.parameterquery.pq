// Parameter query: retrieves the foodmart.customer table from HiveSample.
// Update the host and port to match your Hive LLAP instance before running tests.
let
    Source   = HiveSample.Contents("127.0.0.1", 10500),
    Database = Source{[Name = "HIVE",     Kind = "Database"]}[Data],
    Schema   = Database{[Name = "foodmart", Kind = "Schema"]}[Data],
    Table    = Schema{[Name = "customer",   Kind = "Table"]}[Data]
in
    Table

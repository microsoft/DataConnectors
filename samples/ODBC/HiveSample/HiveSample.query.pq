// Tested with Hortonworks Sandbox
let
    Source = HiveSample.Contents("127.0.0.1", 10500),
    HIVE_Database = Source{[Name = "HIVE", Kind = "Database"]}[Data],
    foodmart_Schema = HIVE_Database{[Name = "foodmart", Kind = "Schema"]}[Data],
    customer_Table = foodmart_Schema{[Name = "customer", Kind = "Table"]}[Data],
    #"Kept First Rows" = Table.FirstN(customer_Table, 5)
in
    #"Kept First Rows"

// Tested with Hortonworks Sandbox
let
    Source = HiveSample.Contents("127.0.0.1", 443),
    HIVE_Database = Source{[Name = "HIVE", Kind = "Database"]}[Data],
    foodmart_Schema = HIVE_Database{[Name = "default", Kind = "Schema"]}[Data],
    customer_Table = foodmart_Schema{[Name = "store_sales", Kind = "Table"]}[Data],
    #"Kept First Rows" = Table.FirstN(customer_Table, 5)
in
    #"Kept First Rows"

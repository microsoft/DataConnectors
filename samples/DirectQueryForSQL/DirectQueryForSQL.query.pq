//Use this file to write queries.
let
    Host = "localhost",
    Database = "AdventureWorksDW2012",
    Source = DirectSQL.Database(Host, Database),
    dbo_Schema = Source{[Name="dbo",Kind="Schema"]}[Data]
in
    dbo_Schema
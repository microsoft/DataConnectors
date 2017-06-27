//
// Use this file to write test queries to run from Visual Studio.
// Documentation: https://github.com/Microsoft/DataConnectors/blob/master/docs/m-extensions.md#query-file
//
let
    Host = "localhost",
    Database = "AdventureWorksDW2012",
    Source = DirectSQL.Database(Host, Database, null),
    dbo_Schema = Source{[Name="dbo",Kind="Schema"]}[Data]
in
    dbo_Schema

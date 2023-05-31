// Use this file to write queries to test your data connector
let
    result = SqlODBC.Contents("localhost"),
    db = result{[Name = "master"]}[Data],
    schema = db{[Name = "sys"]}[Data],
    allViews = schema{[Name = "all_views"]}[Data]
in
    Table.FirstN(allViews, 5)

# Helper Functions

This file contains a number of helper functions commonly used in M extensions.
These functions may eventually be moved to the official M library, but for now can be copied into your extension file code.
You should not mark any of these functions as `shared` within your extension code. 

## Navigation Tables

### Table.ToNavigationTable

This function adds the table type metadata needed for your extension to return a table value that Power Query can recognize as a Navigation Tree. 

```
Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;
```

| Parameter      | Details         |
|:---------------|:----------------|
| table          | Your navigation table.   |
| keyColumns     | List of column names that act as the primary key for your navigation table      |
| nameColumn     | The name of the column that should be used as the display name in the navigator |
| dataColumn     | The name of the column that contains the Table or Function to display           |
| itemKindColumn | The name of the column to use to determine the type of icon to display. Valid values for the column are `Table` and `Function`.    |
| itemNameColumn | The name of the column to use to determine the type of tooltip to display. Valid values for the column are `Table` and `Function`. |
| isLeafColumn   | The name of the column used to determine if this is a leaf node, or if the node can be expanded to contain another navigation table. |

**Example usage:**

```
shared MyExtension.Contents = () =>
    let
        objects = #table(
            {"Name",       "Key",        "Data",                           "ItemKind", "ItemName", "IsLeaf"},{
            {"Item1",      "item1",      #table({"Column1"}, {{"Item1"}}), "Table",    "Table",    true},
            {"Item2",      "item2",      #table({"Column1"}, {{"Item2"}}), "Table",    "Table",    true},
            {"Item3",      "item3",      FunctionCallThatReturnsATable(),  "Table",    "Table",    true},            
            {"MyFunction", "myfunction", AnotherFunction.Contents(),       "Function", "Function", true}
            }),
        NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTable;
```

## URI Manipulation

### Uri.FromParts

This function constructs a full URL based on individual fields in the record. It acts as the reverse of [Uri.Parts](https://msdn.microsoft.com/en-us/library/mt260886).

```
Uri.FromParts = (parts) =>
    let
        port = if (parts[Scheme] = "https" and parts[Port] = 443) or (parts[Scheme] = "http" and parts[Port] = 80) then "" else ":" & Text.From(parts[Port]),
        div1 = if Record.FieldCount(parts[Query]) > 0 then "?" else "",
        div2 = if Text.Length(parts[Fragment]) > 0 then "#" else "",
        uri = Text.Combine({parts[Scheme], "://", parts[Host], port, parts[Path], div1, Uri.BuildQueryString(parts[Query]), div2, parts[Fragment]})
    in
        uri;
```

### Uri.GetHost

This function returns the scheme, host, and default port (for HTTP/HTTPS) for a given URL. For example, `https://bing.com/subpath/query?param=1&param2=hello` would become `https://bing.com:443`. 

```
Uri.GetHost = (url) =>
    let
        parts = Uri.Parts(url),
        port = if (parts[Scheme] = "https" and parts[Port] = 443) or (parts[Scheme] = "http" and parts[Port] = 80) then "" else ":" & Text.From(parts[Port])
    in
        parts[Scheme] & "://" & parts[Host] & port;
```

## Retrieving Data

### Value.WaitFor

This function is useful when making an asynchronous HTTP request, and you need to poll the server until the request is complete. 

```
Value.WaitFor = (producer as function, interval as function, optional count as number) as any =>
    let
        list = List.Generate(
            () => {0, null},
            (state) => state{0} <> null and (count = null or state{0} < count),
            (state) => if state{1} <> null then {null, state{1}} else {1 + state{0}, Function.InvokeAfter(() => producer(state{0}), interval(state{0}))},
            (state) => state{1})
    in
        List.Last(list);
```
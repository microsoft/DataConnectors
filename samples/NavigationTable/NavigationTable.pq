// This file contains your Data Connector logic
section NavigationTable;

[DataSource.Kind="NavigationTable", Publish="NavigationTable.Publish"]
shared NavigationTable.Simple = () as table =>
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

[DataSource.Kind="NavigationTable", Publish="NavigationTable.Publish2"]
shared NavigationTable.Nested = () as table =>
    let
        objects = #table(
            {"Name",       "Key",  "Data",                "ItemKind", "ItemName", "IsLeaf"},{
            {"Nested A",   "n1",   CreateNavTable("AAA"), "Table",    "Table",    false},
            {"Nested B",   "n2",   CreateNavTable("BBB"), "Table",    "Table",    false},
            {"Nested C",   "n3",   CreateNavTable("CCC"), "Table",    "Table",    false}
        }),
        NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTable;

// Data Source Kind description
NavigationTable = [
    Authentication = [
        Implicit = []
    ],
    Label = "Navigation Table Sample"
];

// Data Source UI publishing description
NavigationTable.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "NavTable Simple", "NavTable Simple" }
];

// Data Source UI publishing description
NavigationTable.Publish2 = [
    Beta = true,
    Category = "Other",
    ButtonText = { "NavTable Nested", "NavTable Nested" }
];

// Implementation functions
FunctionCallThatReturnsATable = () as table => #table({"DynamicColumn"}, {{"Dynamic Value"}});
AnotherFunction.Contents = () => "Returns a static string when invoked.";

CreateNavTable = (message as text) as table => 
    let
        objects = #table(
            {"Name",  "Key",   "Data",                           "ItemKind", "ItemName", "IsLeaf"},{
            {"Item1", "item1", #table({"Column1"}, {{message}}), "Table",    "Table",    true},
            {"Item2", "item2", #table({"Column1"}, {{message}}), "Table",    "Table",    true}
        }),
        NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTable;

// Common library code

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
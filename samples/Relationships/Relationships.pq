// This sample shows how to define relationships between tables that 
// will be automatically detected in Power BI Desktop.
section Relationships;

// Base navigation table, no relationships set
[DataSource.Kind="Relationships", Publish="Relationships.PublishNone"]
shared Relationships.None = () =>
    let
        base = #table(type table [ Name = Text.Type, Data = Table.Type ], {
            { "Customers", Customers },
            { "Orders", Orders },
            { "OrderDetails", OrderDetails }
        }),

        nav = CreateNavTable(base)
    in
        nav;

// Relationships set using Table.NestedJoin.
// This function leaves the joined columns on the Orders table,
// which makes it easy for a consumer to expand/merge the tables inline.
[DataSource.Kind="Relationships", Publish="Relationships.PublishNested"]
shared Relationships.Nested = () =>
    let
        ordersWithDetail = Table.NestedJoin(
            Orders, {"OrderId"},
            OrderDetails, {"OrderId"},
            "OrderDetails",
            JoinKind.LeftOuter),
        ordersWithCustomers = Table.NestedJoin(
            ordersWithDetail, { "CustomerId" },
            Customers, {"CustomerId" },
            "Customer",
            JoinKind.LeftOuter),

        base = #table(type table [ Name = Text.Type, Data = Table.Type ], {
            { "Customers", Customers },
            { "Orders", ordersWithCustomers },
            { "OrderDetails", OrderDetails }
        }),

        nav = CreateNavTable(base)
    in
        nav;

// Relationships set using Table.NestedJoin.
// This function removes the joined columns, but
// leaves the relationship metadata in place.
[DataSource.Kind="Relationships", Publish="Relationships.PublishImplicit"]
shared Relationships.Implicit = () =>
    let
        ordersWithDetail = Table.NestedJoin(
            Orders, {"OrderId"},
            OrderDetails, {"OrderId"},
            "OrderDetails",
            JoinKind.LeftOuter),
        ordersWithCustomers = Table.NestedJoin(
            ordersWithDetail, { "CustomerId" },
            Customers, {"CustomerId" },
            "Customer",
            JoinKind.LeftOuter),

        // remove the join columns
        removedJoins = Table.RemoveColumns(ordersWithCustomers, {"OrderDetails", "Customer"}),

        base = #table(type table [ Name = Text.Type, Data = Table.Type ], {
            { "Customers", Customers },
            { "Orders", removedJoins },
            { "OrderDetails", OrderDetails }
        }),

        nav = CreateNavTable(base)
    in
        nav;

// common function to generate format the results into a nav table.
// expects table with columns { "Name", "Data" }
CreateNavTable = (base as table) as table =>
    let
        withItemKind = Table.AddColumn(base, "ItemKind", each "Table", type text),
        withItemName = Table.AddColumn(withItemKind, "ItemName", each "Table", type text),
        withIsLeaf = Table.AddColumn(withItemName, "IsLeaf", each true, type logical),
        navTable = Table.ToNavigationTable(withIsLeaf, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

// Static tables for the sample
Customers = Table.AddKey(#table(type table [CustomerId = Int64.Type, Name = Text.Type], {
    { 1, "Tom"},
    { 2, "Bob"},
    { 3, "Mary"}
}), {"CustomerId"}, true);

Orders = Table.AddKey(#table(type table [OrderId = Int64.Type, CustomerId = Int64.Type, OrderDate = Date.Type], {
    { 1, 1, #date(2018, 1, 1) },
    { 2, 1, #date(2018, 2, 1) },
    { 3, 1, #date(2018, 3, 1) },
    { 4, 1, #date(2018, 4, 1) },
    { 5, 3, #date(2018, 5, 1) },
    { 6, 3, #date(2018, 6, 1) },
    { 7, 3, #date(2018, 7, 1) }
}), {"OrderId"}, true);

OrderDetails = Table.AddKey(#table(type table [OrderId = Int64.Type, LineItem = Int16.Type, Detail = Text.Type, Amount = Currency.Type], {
    { 1, 1, "Book", 5.30 },
    { 1, 2, "Book", 3.99 },
    { 1, 3, "Supplies", 89.99 },
    { 2, 1, "Book", 5.30 },
    { 3, 1, "Book", 2.00 },
    { 3, 2, "Supplies", 1.54 },
    { 4, 1, "Book", 2.00 },
    { 5, 1, "Book", 2.00 },
    { 6, 1, "Book", 2.00 },
    { 7, 1, "Book", 2.00 }
}), {"OrderId", "LineItem"}, true);

// Data Source Kind description
Relationships = [
    Authentication = [
        Anonymous = []
    ]
];

Relationships.PublishNone= [
    Beta = true,
    Category = "Other",
    ButtonText = { "Relationship - None", "Relationship - None" },
    LearnMoreUrl = "https://powerbi.microsoft.com/"
];

Relationships.PublishNested = [
    Beta = true,
    Category = "Other",
    ButtonText = { "Relationship - Nested", "Relationship - Nested" },
    LearnMoreUrl = "https://powerbi.microsoft.com/"
];

Relationships.PublishImplicit = [
    Beta = true,
    Category = "Other",
    ButtonText = { "Relationship - Implicit", "Relationship - Implicit" },
    LearnMoreUrl = "https://powerbi.microsoft.com/"
];

// 
// Load common library functions
// 
// TEMPORARY WORKAROUND until we're able to reference other M modules
Extension.LoadFunction = (name as text) =>
    let
        binary = Extension.Contents(name),
        asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

Table.ToNavigationTable = Extension.LoadFunction("Table.ToNavigationTable.pqm");

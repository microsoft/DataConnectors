section TripPin;

//
// Definition
//
// Data Source Kind description
TripPin = [
    Authentication = [
        Anonymous = []
    ],
    Label = "TripPin Part 5 - Paging"
];

// Data Source UI publishing description
TripPin.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {"TripPin Paging", "TripPin Paging"}
];

//
// Implementation
//
DefaultRequestHeaders = [
    // column name and values only
    #"Accept" = "application/json;odata.metadata=minimal",
    // we only support v4
    #"OData-MaxVersion" = "4.0"
];

BaseUrl = "http://services.odata.org/v4/TripPinService/";

RootEntities = {"Airlines", "Airports", "People"};

[DataSource.Kind = "TripPin", Publish = "TripPin.Publish"]
shared TripPin.Contents = () => TripPinNavTable(BaseUrl) as table;

TripPinNavTable = (url as text) as table =>
    let
        entitiesAsTable = Table.FromList(RootEntities, Splitter.SplitByNothing()),
        rename = Table.RenameColumns(entitiesAsTable, {{"Column1", "Name"}}),
        // Add Data as a calculated column
        withData = Table.AddColumn(rename, "Data", each TripPin.Feed(Uri.Combine(url, [Name])), type table),
        // Add ItemKind and ItemName as fixed text values
        withItemKind = Table.AddColumn(withData, "ItemKind", each "Table", type text),
        withItemName = Table.AddColumn(withItemKind, "ItemName", each "Table", type text),
        // Indicate that the node should not be expandable
        withIsLeaf = Table.AddColumn(withItemName, "IsLeaf", each true, type logical),
        // Generate the nav table
        navTable = Table.ToNavigationTable(withIsLeaf, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

TripPin.Feed = (url as text) as table => GetAllPagesByNextLink(url);

GetPage = (url as text) as table =>
    let
        response = Web.Contents(url, [Headers = DefaultRequestHeaders]),
        body = Json.Document(response),
        nextLink = GetNextLink(body),
        data = Table.FromRecords(body[value])
    in
        data meta [NextLink = nextLink];

// Read all pages of data.
// After every page, we check the "NextLink" record on the metadata of the previous request.
// Table.GenerateByPage will keep asking for more pages until we return null.
GetAllPagesByNextLink = (url as text) as table =>
    Table.GenerateByPage(
        (previous) =>
            let
                // if previous is null, then this is our first page of data
                nextLink = if (previous = null) then url else Value.Metadata(previous)[NextLink]?,
                // if NextLink was set to null by the previous call, we know we have no more data
                page = if (nextLink <> null) then GetPage(nextLink) else null
            in
                page
    );

// In this implementation, 'response' will be the parsed body of the response after the call to Json.Document.
// We look for the '@odata.nextLink' field and simply return null if it doesn't exist.
GetNextLink = (response) as nullable text => Record.FieldOrDefault(response, "@odata.nextLink");

//
// Common functions
//
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
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta [
            NavigationTable.NameColumn = nameColumn,
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn,
            Preview.DelayColumn = itemNameColumn,
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;

// The getNextPage function takes a single argument and is expected to return a nullable table
Table.GenerateByPage = (getNextPage as function) as table =>
    let
        listOfPages = List.Generate(
            // get the first page of data
            () => getNextPage(null),
            // stop when the function returns null
            (lastPage) => lastPage <> null,
            // pass the previous page to the next function call
            (lastPage) => getNextPage(lastPage)
        ),
        // concatenate the pages together
        tableOfPages = Table.FromList(listOfPages, Splitter.SplitByNothing(), {"Column1"}),
        firstRow = tableOfPages{0} ?
    in
        // if we didn't get back any pages of data, return an empty table
        // otherwise set the table type based on the columns of the first page
        if (firstRow = null) then
            Table.FromRows({})
        else
            Value.ReplaceType(
                Table.ExpandTableColumn(tableOfPages, "Column1", Table.ColumnNames(firstRow[Column1])),
                Value.Type(firstRow[Column1])
            );

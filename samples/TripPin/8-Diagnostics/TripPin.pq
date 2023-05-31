section TripPin;

// Data Source Kind description
TripPin = [
    Authentication = [
        Anonymous = []
    ],
    Label = "TripPin Part 8 - Diagnostics"
];

// Data Source UI publishing description
TripPin.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {"TripPin Diagnostics", "TripPin Diagnostics"}
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

// Define our top level table types
AirlinesType = type table [AirlineCode = text, Name = text];

AirportsType = type table [Name = text, IataCode = text, Location = LocationType];

PeopleType = type table [
    UserName = text,
    FirstName = text,
    LastName = text,
    Emails = {text},
    AddressInfo = {nullable LocationType},
    Gender = nullable text,
    Concurrency = Int64.Type
];

// remaining structured types
LocationType = type [Address = text, City = CityType, Loc = LocType];

CityType = type [CountryRegion = text, Name = text, Region = text];

LocType = type [#"type" = text, coordinates = {number}, crs = CrsType];

CrsType = type [#"type" = text, properties = record];

SchemaTable = #table(
    {"Entity", "Type"}, {{"Airlines", AirlinesType}, {"Airports", AirportsType}, {"People", PeopleType}}
);

GetSchemaForEntity = (entity as text) as type =>
    try
        SchemaTable{[Entity = entity]}[Type]
    otherwise
        let
            message = Text.Format("Couldn't find entity: '#{0}'", {entity})
        in
            Diagnostics.Trace(TraceLevel.Error, message, () => error message, true);

[DataSource.Kind = "TripPin", Publish = "TripPin.Publish"]
shared TripPin.Contents = () => TripPinNavTable(BaseUrl) as table;

TripPinNavTable = (url as text) as table =>
    let
        // Use our schema table as the source of top level items in the navigation tree
        entities = Table.SelectColumns(SchemaTable, {"Entity"}),
        rename = Table.RenameColumns(entities, {{"Entity", "Name"}}),
        // Add Data as a calculated column
        // withData = Table.AddColumn(rename, "Data", each Diagnostics.LogFailure("Error in GetEntity", () => GetEntity(url, "DoesNotExist")), type table),
        // withData = Table.AddColumn(rename, "Data", each GetEntity(url, "DoesNotExist"), type table),
        withData = Table.AddColumn(rename, "Data", each GetEntity(url, [Name]), type table),
        // Add ItemKind and ItemName as fixed text values
        withItemKind = Table.AddColumn(withData, "ItemKind", each "Table", type text),
        withItemName = Table.AddColumn(withItemKind, "ItemName", each "Table", type text),
        // Indicate that the node should not be expandable
        withIsLeaf = Table.AddColumn(withItemName, "IsLeaf", each true, type logical),
        // Generate the nav table
        navTable = Table.ToNavigationTable(withIsLeaf, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

TripPin.Feed = (url as text, optional schema as type) as table =>
    let
        _url = Diagnostics.LogValue("Accessing url", url),
        _schema = Diagnostics.LogValue("Schema type", schema),
        // result = GetAllPagesByNextLink(url, schema)
        result = GetAllPagesByNextLink(_url, _schema)
    in
        result;

GetEntity = (url as text, entity as text) as table =>
    let
        fullUrl = Uri.Combine(url, entity),
        schema = GetSchemaForEntity(entity),
        result = TripPin.Feed(fullUrl, schema),
        appliedSchema = Table.ChangeType(result, schema)
    in
        appliedSchema;

GetPage = (url as text, optional schema as type) as table =>
    let
        response = Web.Contents(url, [Headers = DefaultRequestHeaders]),
        body = Json.Document(response),
        nextLink = GetNextLink(body),
        // If we have no schema, use Table.FromRecords() instead
        // (and hope that our results all have the same fields).
        // If we have a schema, expand the record using its field names
        data =
            if (schema = null) then
                Diagnostics.LogFailure(
                    "Error converting response body. Are the records uniform?", () => Table.FromRecords(body[value])
                )
            else
                let
                    // convert the list of records into a table (single column of records)
                    asTable = Table.FromList(body[value], Splitter.SplitByNothing(), {"Column1"}),
                    fields = Record.FieldNames(Type.RecordFields(Type.TableRow(schema))),
                    expanded = Table.ExpandRecordColumn(asTable, "Column1", fields)
                in
                    expanded
    in
        data meta [NextLink = nextLink];

// Read all pages of data.
// After every page, we check the "NextLink" record on the metadata of the previous request.
// Table.GenerateByPage will keep asking for more pages until we return null.
GetAllPagesByNextLink = (url as text, optional schema as type) as table =>
    Table.GenerateByPage(
        (previous) =>
            let
                // if previous is null, then this is our first page of data
                nextLink = if (previous = null) then url else Value.Metadata(previous)[NextLink]?,
                // if NextLink was set to null by the previous call, we know we have no more data
                page = if (nextLink <> null) then GetPage(nextLink, schema) else null
            in
                page
    );

// In this implementation, 'response' will be the parsed body of the response after the call to Json.Document.
// We look for the '@odata.nextLink' field and simply return null if it doesn't exist.
GetNextLink = (response) as nullable text => Record.FieldOrDefault(response, "@odata.nextLink");

//
// Load common library functions
//
// TEMPORARY WORKAROUND until we're able to reference other M modules
Extension.LoadFunction = (name as text) =>
    let
        binary = Extension.Contents(name), asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

Table.ChangeType = Extension.LoadFunction("Table.ChangeType.pqm");
Table.GenerateByPage = Extension.LoadFunction("Table.GenerateByPage.pqm");
Table.ToNavigationTable = Extension.LoadFunction("Table.ToNavigationTable.pqm");

// Diagnostics module contains multiple functions. We can take the ones we need.
Diagnostics = Extension.LoadFunction("Diagnostics.pqm");

Diagnostics.LogValue = Diagnostics[LogValue];
Diagnostics.LogFailure = Diagnostics[LogFailure];

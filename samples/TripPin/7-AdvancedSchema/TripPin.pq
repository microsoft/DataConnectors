section TripPin;

//
// Definition
//

// Data Source Kind description
TripPin = [
    Authentication = [
        Implicit = []
    ],
    Label = "TripPin Part 7 - Advanced Schema"
];

// Data Source UI publishing description
TripPin.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "TripPin Advanced Schema", "TripPin Advanced Schema" }
];

//
// Implementation
// 

DefaultRequestHeaders = [
    #"Accept" = "application/json;odata.metadata=minimal",  // column name and values only
    #"OData-MaxVersion" = "4.0"                             // we only support v4
];

BaseUrl = "http://services.odata.org/v4/TripPinService/";

// Define our top level table types
AirlinesType = type table [ AirlineCode = text, Name = text ];

AirportsType = type table [
    Name = text,
    IataCode = text,
    Location = LocationType
];

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
LocationType = type [
    Address = text,
    City = CityType,
    Loc = LocType
];

CityType = type [
    CountryRegion = text,
    Name = text,
    Region = text
];

LocType = type [
    #"type" = text,
    coordinates = {number},
    crs = CrsType
];

CrsType = type [
    #"type" = text,
    properties = record
];

SchemaTable = #table({"Entity", "Type"}, {
    {"Airlines", AirlinesType },    
    {"Airports", AirportsType },
    {"People", PeopleType}    
});
        
GetSchemaForEntity = (entity as text) as type => try SchemaTable{[Entity=entity]}[Type] otherwise error "Couldn't find entity: '" & entity &"'";

[DataSource.Kind="TripPin", Publish="TripPin.Publish"]
shared TripPin.Contents = () => TripPinNavTable(BaseUrl) as table;

TripPinNavTable = (url as text) as table =>
    let
        // Use our schema table as the source of top level items in the navigation tree
        entities = Table.SelectColumns(SchemaTable, {"Entity"}),
        rename = Table.RenameColumns(entities, {{"Entity", "Name"}}),
        // Add Data as a calculated column
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

TripPin.Feed = (url as text, optional schema as type) as table => GetAllPagesByNextLink(url, schema);

GetEntity = (url as text, entity as text) as table => 
    let
        fullUrl = Uri.Combine(url, entity),
        schema = GetSchemaForEntity(entity),
        result = TripPin.Feed(fullUrl, schema)
    in
        result;

GetPage = (url as text, optional schema as type) as table =>
    let
        response = Web.Contents(url, [ Headers = DefaultRequestHeaders ]),        
        body = Json.Document(response),
        nextLink = GetNextLink(body),
        data = Table.FromRecords(body[value]),
        // enforce the schema
        withSchema = if (schema <> null) then Table.ChangeType(data, schema) else data
    in
        withSchema meta [NextLink = nextLink];

// Read all pages of data.
// After every page, we check the "NextLink" record on the metadata of the previous request.
// Table.GenerateByPage will keep asking for more pages until we return null.
GetAllPagesByNextLink = (url as text, optional schema as type) as table =>
    Table.GenerateByPage((previous) => 
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

// The getNextPage function takes a single argument and is expected to return a nullable table
Table.GenerateByPage = (getNextPage as function) as table =>
    let        
        listOfPages = List.Generate(
            () => getNextPage(null),            // get the first page of data
            (lastPage) => lastPage <> null,     // stop when the function returns null
            (lastPage) => getNextPage(lastPage) // pass the previous page to the next function call
        ),
        // concatenate the pages together
        tableOfPages = Table.FromList(listOfPages, Splitter.SplitByNothing(), {"Column1"}),
        firstRow = tableOfPages{0}?
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

//
// Schema functions
//

Table.ChangeType = (table as table, _type as type) as table =>
    if (not Type.Is(_type, type table)) then error "type argument should be a table type" else
    let
        columnsForType = Type.RecordFields(Type.TableRow(_type)),
        columnsAsTable = Record.ToTable(columnsForType),
        schema = Table.ExpandRecordColumn(columnsAsTable, "Value", {"Type"}, {"Type"}),
        previousMeta = Value.Metadata(_type),

        reordered = Table.SelectColumns(table, schema[Name], MissingField.UseNull),

        // process primitive values - this will call Table.TransformColumnTypes
        map = (t) => if Type.Is(t, type table) or Type.Is(t, type list) or Type.Is(t, type record) or t = type any then null else t,        
        mapped = Table.TransformColumns(schema, {"Type", map}),
        omitted = Table.SelectRows(mapped, each [Type] <> null),
        existingColumns = Table.ColumnNames(reordered),
        removeMissing = Table.SelectRows(omitted, each List.Contains(existingColumns, [Name])),
        primativeTransforms = Table.ToRows(removeMissing),
        changedPrimatives = Table.TransformColumnTypes(reordered, primativeTransforms),
        
        // Get the list of transforms we'll use for Record types
        recordColumns = Table.SelectRows(schema, each Type.Is([Type], type record)),
        recordTypeTransformations = Table.AddColumn(recordColumns, "RecordTransformations", each (r) => Record.ChangeType(r, [Type]), type function),
        recordChanges = Table.ToRows(Table.SelectColumns(recordTypeTransformations, {"Name", "RecordTransformations"})),

        // Get the list of transforms we'll use for List types
        listColumns = Table.SelectRows(schema, each Type.Is([Type], type list)),
        listTransforms = Table.AddColumn(listColumns, "ListTransformations", each (t) => Value.ReplaceType(t, [Type]), Function.Type),
        listChanges = Table.ToRows(Table.SelectColumns(listTransforms, {"Name", "ListTransformations"})),

        // TODO: Do we need to do Tables as well, or will they always be lists of records?

        // Perform all of our transformations
        allColumnTransforms = recordChanges & listChanges,
        changedRecordTypes = if (List.IsEmpty(allColumnTransforms)) then changedPrimatives else Table.TransformColumns(changedPrimatives, allColumnTransforms, null, MissingField.Ignore),

        // set final type
        withType = Value.ReplaceType(changedRecordTypes, _type)
    in
        if (List.IsEmpty(Record.FieldNames(columnsForType))) then table else withType meta previousMeta;

// If given a generic record type (no predefined fields), the original record is returned
Record.ChangeType = (record as record, recordType as type) =>
    let
        // record field format is [ fieldName = [ Type = type, Optional = logical], ... ]
        fields = try Type.RecordFields(recordType) otherwise error "Record.ChangeType: failed to get record fields. Is this a record type?",
        fieldNames = Record.FieldNames(fields),
        fieldTable = Record.ToTable(fields),
        optionalFields = Table.SelectRows(fieldTable, each [Value][Optional])[Name],
        requiredFields = List.Difference(fieldNames, optionalFields),
        // make sure all required fields exist
        withRequired = Record.SelectFields(record, requiredFields, MissingField.UseNull),
        // append optional fields
        withOptional = withRequired & Record.SelectFields(record, optionalFields, MissingField.Ignore),
        // set types
        transforms = GetTransformsForType(recordType),
        withTypes = Record.TransformFields(withOptional, transforms, MissingField.Ignore),
        // order the same as the record type
        reorder = Record.ReorderFields(withTypes, fieldNames, MissingField.Ignore)
    in
        if (List.IsEmpty(fieldNames)) then record else reorder;

// Returns a table type for the provided schema table
Schema.ToTableType = (schema as table) as type =>
    let
        toList = List.Transform(schema[Type], (t) => [Type=t, Optional=false]),
        toRecord = Record.FromList(toList, schema[Name]),
        toType = Type.ForRecord(toRecord, false),
        previousMeta = Value.Metadata(schema)
    in
        type table (toType) meta previousMeta;

// Returns a list of transformations that can be passed to Table.TransformColumns, or Record.TransformFields
// Format: {"Column", (f) => ...) .... ex: {"A", Number.From}
GetTransformsForType = (_type as type) as list =>
    let
        fieldsOrColumns = if (Type.Is(_type, type record)) then Type.RecordFields(_type)
                     else if (Type.Is(_type, type table)) then Type.RecordFields(Type.TableRow(_type))
                     else error "GetTransformsForType: record or table type expected",
        toTable = Record.ToTable(fieldsOrColumns),
        transformColumn = Table.AddColumn(toTable, "Transform", each GetTransformByType([Value][Type]), Function.Type),
        transformMap = Table.ToRows(Table.SelectColumns(transformColumn, {"Name", "Transform"}))
    in
        transformMap;

GetTransformByType = (_type as type) as function =>
         if (Type.Is(_type, type number)) then Number.From
    else if (Type.Is(_type, type text)) then Text.From
    else if (Type.Is(_type, type date)) then Date.From
    else if (Type.Is(_type, type datetime)) then DateTime.From
    else if (Type.Is(_type, type duration)) then Duration.From
    else if (Type.Is(_type, type datetimezone)) then DateTimeZone.From
    else if (Type.Is(_type, type logical)) then Logical.From
    else if (Type.Is(_type, type time)) then Time.From
    else if (Type.Is(_type, type record)) then (t) => if (t <> null) then @Record.ChangeType(t, _type) else t
    else if (Type.Is(_type, type table)) then (t) => if (t <> null) then @Table.ChangeType(t, _type) else t
    else if (Type.Is(_type, type list)) then (t) => if (t <> null) then Value.ReplaceType(t, _type) else t
    else (t) => t;

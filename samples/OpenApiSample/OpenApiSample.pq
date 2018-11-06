section OpenApiSample;

DefaultOptions = [ 
    // The built-in credential handling for OpenApi.Document only works
    // with Basic (UsernamePassword) auth. All other types should be handled
    // explicitly using the ManualCredentials option.
    //
    // In the this sample, all of the calls we'll make will work anonymously.
    // We can force anonymous access by setting ManualCredentials to true, and then
    // not setting any additional request headers/parameters.
    //
    ManualCredentials = true,
    // The returned data will match the schema defined in the swagger file. 
    // This means that additional fields and object types that don't have explicit
    // properties defined will be ignored. To see all results, we set the IncludeMoreColumns
    // option to true. Any fields found in the response that aren't found in the schema will
    // be grouped under this column in a record value.
    //
    IncludeMoreColumns = true,
    // When IncludeExtensions is set to true, vendor extensions in the swagger ("x-*" fields)
    // will be included as meta values on the function.
    //
    IncludeExtensions = true
];

[DataSource.Kind="OpenApiSample", Publish="OpenApiSample.Petstore.Publish"]
shared OpenApiSample.Petstore = () =>
    let
        // Pull the latest swagger definition from the site 
        swaggerUrl = "http://petstore.swagger.io/v2/swagger.json",
        swagger = Web.Contents(swaggerUrl),
        // OpenApi.Document will return a navigation table
        nav = OpenApi.Document(swagger, DefaultOptions)
    in
        nav;

[DataSource.Kind="OpenApiSample", Publish="OpenApiSample.ApisGuru.Publish"]
shared OpenApiSample.ApisGuru = () =>
    let
        // load the swagger definition from the bundled resource file
        Swagger = Extension.Contents("apisGuru.json"),

        // OpenApi.Document returns a navigation table. Each GET operation defined
        // in the swagger document is becomes a row in the nav table. Each row is a 
        // function that can be invoked by the user.
        defaultNav = OpenApi.Document(Swagger, DefaultOptions),
        // The Apis.Guru swagger has a listAPIs function - we'll get a reference to that
        listAPIs = defaultNav{[Name="listAPIs"]}[Data],
        allAPIs = listAPIs(),
        // format the results as the nav table we will return
        nav = ApiGuru.FormatApiList(allAPIs)
    in
        nav;

// Process the results of the ApisGuru listAPIs function to return a 
// navigation table with all published APIs.
ApiGuru.FormatApiList = (results as record) as table =>
    if (results[MoreColumns]? = null) then error "[MoreColumns] not found in result" else
    let
        // expand down to the level that provides us with the swagger URL
        MoreColumns = results[MoreColumns],
        toTable = Record.ToTable(MoreColumns),
        expandAPI = Table.ExpandRecordColumn(toTable, "Value", {"added", "preferred", "versions"}),
        getPreferredVersion = Table.AddColumn(expandAPI, "api", each try Record.Field([versions], [preferred]) otherwise null),
        expandSwaggerInfo = Table.ExpandRecordColumn(getPreferredVersion, "api", {"info", "swaggerUrl", "updated"}),
        // the [Data] column of our navigator will be another call to OpenApi.Document, passing in the swagger for this endpoint
        withData = Table.AddColumn(expandSwaggerInfo, "Data", each OpenApi.Document(Web.Contents([swaggerUrl]), DefaultOptions), Table.Type),
        withKind = Table.AddColumn(withData, "ItemKind", each "Feed", Text.Type),
        withName = Table.AddColumn(withKind, "ItemName", each "Table", Text.Type),
        withLeaf = Table.AddColumn(withName, "IsLeaf", each false, Logical.Type),
        asNav = Table.ToNavigationTable(withLeaf, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        asNav;

// Data Source Kind description
OpenApiSample = [
    Authentication = [
        Anonymous = []
    ]
];

// Data Source UI publishing description
OpenApiSample.ApisGuru.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "Swagger sample - APIs Guru", "Swagger sample - APIs Guru" },
    LearnMoreUrl = "https://powerbi.microsoft.com/"
];

// Data Source UI publishing description
OpenApiSample.Petstore.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "Swagger sample - Petstore", "Swagger sample - Petstore" },
    LearnMoreUrl = "https://powerbi.microsoft.com/"
];

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

section TripPinAnnotations;

// Data Source Kind description
TripPin = [
    // TestConnection is required to enable the connector through the Gateway
    TestConnection = (dataSourcePath) => { "TripPin.Annotations" },
    Authentication = [
        Anonymous = []
    ],
    Label = "AnnotationsSample"
];

// Data Source UI publishing description
TripPin.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "AnnotationsSample", "AnnotationsSample" }
];

[DataSource.Kind="TripPin", Publish="TripPin.Publish"]
shared TripPin.Annotations = () => let
    serviceDocument = TripPin.ServiceDocument()
in
    #table({ "Location", "Data" }, {
        { "Entity Container Annotations", GetEntityContainerAnnotations(serviceDocument) },
        { "Resources", Table.TransformColumns(serviceDocument, { { "Data", (resource) => 
            if resource is function then #table({ "Location", "Data" }, {
                { "Function Import Annotations", GetFunctionImportAnnotations(resource) },
                { "Parameter Annotations", Record.ToTable(GetFunctionParameterAnnotations(Value.Type(resource))) }
            }) else #table({ "Location", "Data" }, {
                { "Entity Set or Singleton", GetEntitySetOrSingletonAnnotations(resource) },
                { "Entity Type", #table({ "Location", "Data" }, {
                    { "Entity Type Annotations", GetEntityTypeAnnotations(resource) },
                    { "Property Annotations", Record.ToTable(GetEntityTypePropertyAnnotations(resource)) },
                    { "Function Annotations", Table.AddColumn(
                         Table.FromColumns(Table.ColumnsOfType(resource, { Function.Type }), { "Name" }),
                         "Value",
                         each GetEntityTypeFunctionAnnotations(resource, [Name])) }
                }) }
            })
    } }) }
});

GetEntityContainerAnnotations = (serviceDocument) => Value.Metadata(Value.Type(serviceDocument));

GetEntitySetOrSingletonAnnotations = (entitySetOrSingleton) => Value.Metadata(entitySetOrSingleton);

GetFunctionImportAnnotations = (functionImport) => Value.Metadata(Value.Type(functionImport));

GetEntityTypeAnnotations = (entitySetOrSingleton) => let
    entityCollectionType = Value.Type(entitySetOrSingleton),
    entityType = Type.TableRow(entityCollectionType),
    entityTypeAnnotations = Value.Metadata(entityType)[OData.Annotations]
in
    entityTypeAnnotations;

GetEntityTypePropertyAnnotations = (entitySetOrSingleton) => let
    entityCollectionType = Value.Type(entitySetOrSingleton),
    entityType = if entitySetOrSingleton is record then entityCollectionType else Type.TableRow(entityCollectionType),
    fieldAnnotations = Value.Metadata(entityType)[OData.FieldAnnotations]
in
    fieldAnnotations;

GetEntityTypeFunctionAnnotations = (entitySetOrSingleton, functionName) => let
    entityCollectionType = Value.Type(entitySetOrSingleton),
    entityType = if entitySetOrSingleton is record then entityCollectionType else Type.TableRow(entityCollectionType),
    functionType = Type.TableColumn(entityType, functionName),
    functionAnnotations = Value.Metadata(functionType)
in
    functionAnnotations;

GetFunctionParameterAnnotations = (functionType) => let
    parameters = Type.FunctionParameters(functionType),
    parametersTable = Record.ToTable(parameters),
    parameterAnnotations = Table.TransformColumns(parametersTable, { { "Value", Value.Metadata } })
in
    Record.FromTable(parameterAnnotations);

BaseUrl = "http://services.odata.org/v4/TripPinService/";

// Without explicitly setting IncludeAnnotations or IncludeMetadataAnnotations, 
// annotations will not be made available
TripPin.ServiceDocument = () => OData.Feed(BaseUrl, null, [ Implementation = "2.0", IncludeAnnotations = "*" ]) as table;
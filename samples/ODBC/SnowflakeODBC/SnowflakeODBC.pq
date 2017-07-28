section SnowflakeODBC;

[DataSource.Kind="SnowflakeODBC", Publish="SnowflakeODBC.UI"]
shared SnowflakeODBC.Databases = (server as text, warehouse as text, options as nullable record) as table =>
    let
        Host = GetHost(server),
        ConnectionTimeoutOption = TimeoutOption(options, "ConnectionTimeout"),
        QueryTimeoutOption = TimeoutOption(options, "CommandTimeout"),
        BaseConnectionString =
            if options <> null and List.Count(List.Difference(Record.FieldNames(options), ValidOptions)) > 0 then
                error Error.Record("Expression.Error", "Unexpected options field")
            else
                [ driver = "SnowflakeDSIIDriver", server = Host, warehouse = warehouse ],
        WithLoginTimeoutOption = AddConnectionStringOption(BaseConnectionString, "login_timeout", ConnectionTimeoutOption),
        WithNetworkTimeoutOption = AddConnectionStringOption(WithLoginTimeoutOption, "network_timeout", ConnectionTimeoutOption),
        ConnectionString = AddConnectionStringOption(WithNetworkTimeoutOption, "query_timeout", QueryTimeoutOption),
        Options = [
            AstVisitor = [
                LimitClause = (skip, take) =>
                    if skip = 0 and take = null then
                        ...
                    else
                        let
                            // While supported in the documented grammar, using OFFSET without LIMIT produces a synax error.
                            take = if take = null then 4611686018427387903 else take
                        in
                            [
                                Text = Text.Format("LIMIT #{0} OFFSET #{1}", { take, skip }),
                                Location = "AfterQuerySpecification"
                            ],
                Constant =
                    let
                        Quote = each Text.Format("'#{0}'", { _ }),
                        Cast = (value, typeName) => [
                            Text = Text.Format("CAST(#{0} as #{1})", { value, typeName })
                        ],
                        Visitor = [
                            // This is to work around parameters being converted to VARCHAR
                            // and to work around driver crash when using TYPE_TIME parameters.
                            NUMERIC = each Cast(_, "NUMERIC"),
                            DECIMAL = each Cast(_, "DECIMAL"),
                            INTEGER = each Cast(_, "INTEGER"),
                            FLOAT = each Cast(_, "FLOAT"),
                            REAL = each Cast(_, "REAL"),
                            DOUBLE = each Cast(_, "DOUBLE"),
                            TYPE_DATE = each Cast(Quote(Date.ToText(_, "yyyy-MM-dd")), "DATE"),
                            TYPE_TIMESTAMP = each Cast(Quote(DateTime.ToText(_, "yyyy-MM-dd HH:mm:ss.sssssss")), "TIMESTAMP"),
                            TYPE_TIME = each Cast(Quote(Time.ToText(_, "HH:mm:ss.sssssss")), "TIME")
                        ]
                    in
                        (typeInfo, ast) => Record.FieldOrDefault(Visitor, typeInfo[TYPE_NAME], each null)(ast[Value])
            ],
            ClientConnectionPooling = true,
            SqlCapabilities = [
                Sql92Conformance = 8, /* SQL_SC_SQL92_FULL */
                FractionalSecondsScale = 3,
                MaxParameters = 50
            ],
            OnError = (errorRecord as record) =>
                if errorRecord[Reason] = DataSourceMissingClientLibrary then
                    error Error.Record(
                        DataSourceMissingClientLibrary, Text.Format(
                        "Missing client library", { DriverDownloadUrl }),
                        DriverDownloadUrl)
                else if errorRecord[Reason] = DataSourceError and not Table.IsEmpty(Table.SelectRows(errorRecord[Detail][OdbcErrors], each [SQLState] = "57P03")) then
                    error Error.Record(
                        DataSourceError,
                        Text.Format("warehouse suspended", { warehouse }),
                        errorRecord[Detail])
                else
                    error errorRecord,

            // This is to work around the driver returning the deprecated
            // TIMESTAMP, DATE and TIME instead of TYPE_TIMESTAMP, TYPE_DATE and TYPE_TIME
            // for column metadata returned by SQLColumns. The column types also don't
            // match the types that are returned by SQLGetTypeInfo.
            SQLColumns = (catalogName, schemaName, tableName, columnName, source) =>
                let
                    OdbcSqlType.DATETIME = 9,
                    OdbcSqlType.TYPE_DATE = 91,
                    OdbcSqlType.TIME = 10,
                    OdbcSqlType.TYPE_TIME = 92,
                    OdbcSqlType.TIMESTAMP = 11,
                    OdbcSqlType.TYPE_TIMESTAMP = 93,

                    FixDataType = (dataType) =>
                        if dataType = OdbcSqlType.DATETIME then
                            OdbcSqlType.TYPE_DATE
                        else if dataType = OdbcSqlType.TIME then
                            OdbcSqlType.TYPE_TIME
                        else if dataType = OdbcSqlType.TIMESTAMP then
                            OdbcSqlType.TYPE_TIMESTAMP
                        else
                            dataType,
                    FixDataTypeName = (dataTypeName) =>
                        if dataTypeName = "TIMESTAMP" then
                            "TYPE_TIMESTAMP"
                        else if dataTypeName = "DATE" then
                            "TYPE_DATE"
                        else if dataTypeName = "TIME" then
                            "TYPE_TIME"
                        else
                            dataTypeName,
                    Transform = Table.TransformColumns(source, { { "DATA_TYPE", FixDataType }, { "TYPE_NAME", FixDataTypeName } })
                in
                    Transform,
            HierarchicalNavigation = true
        ],
        Databases = Odbc.DataSource(ConnectionString, Options),
        Metadata = Value.Metadata(Value.Type(Databases)),
        RemovedInformationSchema = 
            let
                RemoveInformationSchema = (data) => Table.SelectRows(data, each [Name] <> "INFORMATION_SCHEMA"),
                TransformColumns = Table.TransformColumns(Databases, { "Data", RemoveInformationSchema })
            in
                TransformColumns,
        TransformComplexColumns = 
            let
                TransformComplexColumns = (table) => 
                    let
                        TableType = Value.Type(table),
                        Schema = Table.Schema(table),
                        ComplexColumns = Table.ToRecords(Table.SelectRows(Schema, 
                            each [NativeTypeName]  = "STRUCT" or [NativeTypeName] = "ARRAY")),
                        TransformOperations = List.Accumulate(ComplexColumns, table, (state, column) =>
                            let
                                ColumnType = Type.TableColumn(TableType, column[Name]),
                                PreservedFacetFields = { "NativeTypeName", "NativeDefaultExpression", "NativeExpression" },
                                Facets = Record.SelectFields(Type.Facets(ColumnType), PreservedFacetFields),
                                ComplexType = if column[NativeTypeName] = "STRUCT" then type record else type list,
                                AddNullable = if Type.IsNullable(ComplexType) then type nullable ComplexType else ComplexType,
                                TypeWithFacets = Type.ReplaceFacets(AddNullable, Facets),
                                ToNullableJson = (value) => if value = null then null else Json.Document(value),
                                TransformColumn = Table.TransformColumns(state, { column[Name], ToNullableJson, TypeWithFacets })
                            in
                                TransformColumn)
                    in
                        TransformOperations,

                TransformColumnKeepType = (table, columnName, operation) =>
                    let
                        TableType = Value.Type(table),
                        TransformColumn = Table.TransformColumns(table, { columnName, operation, Type.TableColumn(table, columnName) }),
                        ReplaceType = Value.ReplaceType(TransformColumn, TableType)
                    in
                        ReplaceType,

                TransformColumns =  TransformColumnKeepType(RemovedInformationSchema, "Data", 
                    (schemas) => TransformColumnKeepType(schemas, "Data",
                        (tables) => TransformColumnKeepType(tables, "Data",
                            TransformComplexColumns)))
            in
                TransformColumns,
        WithMetadata = Value.ReplaceType(TransformComplexColumns, Value.ReplaceMetadata(Value.Type(RemovedInformationSchema), Metadata))
    in
        WithMetadata;

TimeoutOption = (options as nullable record, name as text) as nullable record =>
    if options <> null and Record.HasFields(options, name) then
        let
            Field = Record.Field(options, name)
        in
            if Field is number and Field >= 0 and NumberIsInteger(Field) then
                Field
            else
                error Error.Record("Expression.Error", "Invalid timeout option")
    else
        null;

GetHost = (server as text) as text =>
    let
        Address = Uri.Parts("http://" & server)
    in
        if Address[Host] = "" 
            or Address[Scheme] <> "http" 
            or Address[Path] <> "/" 
            or Address[Query] <> [] 
            or Address[Fragment] <> ""
            or Address[UserName] <> "" 
            or Address[Password] <> "" 
            or (Address[Port] <> 80 and Address[Port] <> 443) 
            or Text.EndsWith(server, ":80") 
        then 
            error "Invalid server name"
        else 
            Address[Host];

AddConnectionStringOption = (options as record, name as text, value as any) as record =>
    if value = null then
        options
    else
        Record.AddField(options, name, value);

NumberIsInteger = (x as number) => Number.RoundDown(x) = x;
DriverDownloadUrl = "http://go.microsoft.com/fwlink/?LinkID=823762";
ValidOptions = { "ConnectionTimeout", "CommandTimeout" };
DataSourceMissingClientLibrary = "DataSource.MissingClientLibrary";
DataSourceError = "DataSource.Error";

SnowflakeODBC = [
    Authentication = [
        UsernamePassword = []
    ]
];

SnowflakeODBC.UI = [
    ButtonText = { "SnowflakeODBC Sample", "SnowflakeODBC Sample" },
    Category = "Database",
    SupportsDirectQuery = true
];
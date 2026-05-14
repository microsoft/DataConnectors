// DuckDb.pq — Sample DuckDb connector using FlightSQL via Adbc.Connection.
// Demonstrates:
//   - Connecting to DuckDb over FlightSQL (gRPC)
//   - Navigation tree: Databases > Schemas > Tables
//   - Query folding via SqlGenerator
//   - Primary & Foreign key relationships
//   - SQL-based metadata retrieval from information_schema
//
// This connector uses Adbc.Connection only (no Adbc.DataSource, Adbc.Query, or ODBC).
// User-facing parameters are high-level (Server, Encryption, Database).
// All ADBC-level properties (adbc.flight.sql.*) are mapped internally —
// the user never sees or configures raw ADBC keys.
// Credentials (Username/Password, API Key) are handled via Extension.CurrentCredential().
[Version = "1.0.0"]
section DuckDb;

[DataSource.Kind = "DuckDb", Publish = "DuckDb.Publish"]
shared DuckDb.Contents = Value.ReplaceType(DuckDbConnectorImpl, DuckDbConnectorType);

DuckDbConnectorType =
    let
        FunctionType = Type.ForFunction(
            [
                Parameters = [
                    server = (type text) meta [
                        Documentation.FieldCaption = "Server",
                        Documentation.FieldDescription = "The DuckDb FlightSQL server hostname or hostname:port (e.g., localhost:32010)",
                        Documentation.SampleValues = {"localhost:32010", "duckdb.example.com"}
                    ],
                    encryption = (type text) meta [
                        Documentation.FieldCaption = "Encryption",
                        Documentation.FieldDescription = "Whether to use TLS encryption for the gRPC connection",
                        Documentation.AllowedValues = {"Enabled", "Disabled"}
                    ],
                    optional database = (type text) meta [
                        Documentation.FieldCaption = "Database",
                        Documentation.FieldDescription = "Optional: the DuckDb database name to connect to",
                        Documentation.SampleValues = {"my_database"}
                    ]
                ],
                ReturnType = type table
            ],
            2
        ),
        WithDocumentation = Value.ReplaceMetadata(
            FunctionType,
            [
                Documentation.Name = "DuckDb (FlightSQL)",
                Documentation.LongDescription = "Connect to a DuckDb instance via the FlightSQL (gRPC) protocol using ADBC. "
                    & "This sample connector demonstrates Adbc.Connection-based navigation with query folding, "
                    & "type mapping, and relationship detection via primary/foreign keys.",
                Documentation.Examples = {[
                    Description = "Connect to a local DuckDb FlightSQL server",
                    Code = "DuckDb.Contents(""localhost:32010"", ""Disabled"")",
                    Result = "Returns the DuckDb navigation table"
                ]}
            ]
        )
    in
        WithDocumentation;

DuckDbSqlGenerator = Extension.LoadExpression("SqlGenerator.pqm");
FlightSqlAdbcConfig = Extension.LoadExpression("FlightSqlAdbcConfig.pqm");

Adbc.Connection = try #shared[Adbc.Connection] otherwise (driver, databaseProperties, connectionProperties, options) =>
    error Error.Record("Expression.Error", "The Adbc.Connection function is not available in this environment");
Tables.NavigationPropertyGenerator = try #shared[Tables.NavigationPropertyGenerator] otherwise null;

ModuleIdentifier = () => ...;
MakeUniqueIdentifier = (connectionString as record) as record => [Module = ModuleIdentifier, Signature = connectionString];

DuckDbConnectorImpl = (server as text, encryption as text, optional database as text) as table =>
    let
        Address = ParseServerAddress(server),
        EncryptionEnabled = encryption <> "Disabled",
        UriSchema = if EncryptionEnabled then "grpc+tls" else "grpc",
        Uri = UriSchema & "://" & Address[Host] & ":" & Text.From(Address[Port]),

        // Build the connection string from user-friendly parameters.
        // All ADBC-level properties are mapped here — the user never sees them.
        DatabaseHeaders = if database <> null then
            RecordToHeaders([database = database])
        else [],
        CredentialProperties = GetCredentialConnectionProperties(),

        ConnectionString = [uri = Uri] & DatabaseHeaders & CredentialProperties,

        Connection = Adbc.Connection(FlightSqlAdbcConfig, ConnectionString, [], [ConnectionPoolType = 2]),
        ExecuteQueryCtor = (cxn as record) => (sql as text, optional opts as record) =>
            let options = [IsMetadata = opts[IsMetadata]?]
            in cxn[ExecuteQuery](sql, null, options),
        GetData = (query as text, resultType as type, ctx as record) =>
            CreateDataTable(query, resultType, ctx, context[ExecuteQuery]),
        UniqueIdentifier = MakeUniqueIdentifier(ConnectionString),
        SqlGen = SqlView.Generator(UniqueIdentifier, DuckDbSqlGenerator[SqlGenerator], GetData),
        NavPropGenerator = if Tables.NavigationPropertyGenerator = null then null else
            Tables.NavigationPropertyGenerator(null, (path) =>
                AdbcDatabases{[Name = path{0}]}[Data]{[Name = path{1}]}[Data]{[Name = path{2}]}[Data]),
        context = [
            Connection = Connection, ExecuteQuery = ExecuteQueryCtor(Connection),
            ExecuteQueryCtor = ExecuteQueryCtor, SqlGenerator = SqlGen, NavPropGenerator = NavPropGenerator
        ],
        AdbcDatabases = GetDatabases(context, database)
    in AdbcDatabases;

// ============================================================================
// CREDENTIAL HANDLING
// Credentials are provided by Power BI's credential dialog (Extension.CurrentCredential).
// The user selects Username/Password, API Key, or Anonymous in the auth UI —
// this function maps that to the appropriate ADBC connection properties internally.
// ============================================================================
GetCredentialConnectionProperties = () =>
    let
        Credential = Extension.CurrentCredential()
    in
        if Credential[AuthenticationKind]? = "UsernamePassword" then
            [username = Credential[Username], password = Credential[Password]]
        else if Credential[AuthenticationKind]? = "Key" then
            [#"adbc.flight.sql.authorization_header" = "Bearer " & Credential[Key]]
        else
            [];

// ============================================================================
// HEADER HELPERS
// Converts a record of user-friendly key/value pairs into ADBC Flight RPC
// call headers. The user provides values like [database = "mydb"] and this
// maps them to "adbc.flight.sql.rpc.call_header.database" = "mydb" internally.
// ============================================================================
RecordToHeaders = (input as record) as record =>
    let
        NonNullFields = List.Select(Record.FieldNames(input), each Record.Field(input, _) <> null)
    in
        Record.FromList(
            List.Transform(NonNullFields, each Record.Field(input, _)),
            List.Transform(NonNullFields, each "adbc.flight.sql.rpc.call_header." & _)
        );

// ============================================================================
// SERVER ADDRESS PARSING
// Accepts a plain hostname or hostname:port. The user does NOT need to specify
// the gRPC scheme (grpc:// or grpc+tls://) — that is determined by the
// Encryption parameter. Default port is 32010.
// ============================================================================
ParseServerAddress = (server as text) as record =>
    let
        trimmed = Text.Trim(server),
        // Strip any scheme prefix if the user accidentally included one
        withoutScheme =
            if Text.StartsWith(trimmed, "grpc+tls://") then Text.AfterDelimiter(trimmed, "grpc+tls://")
            else if Text.StartsWith(trimmed, "grpc+tcp://") then Text.AfterDelimiter(trimmed, "grpc+tcp://")
            else if Text.StartsWith(trimmed, "grpc://") then Text.AfterDelimiter(trimmed, "grpc://")
            else trimmed,
        hostParts = Text.Split(withoutScheme, ":"),
        host = hostParts{0},
        port = if List.Count(hostParts) = 2 then Number.FromText(hostParts{1}) else 32010
    in
        [Host = host, Port = port];

// ============================================================================
// DATA TABLE CREATION (with Table.View for query folding)
// ============================================================================
CreateDataTable = (query as text, resultType as type, context as record, executeQuery as function) =>
    Table.View(null, [
        GetType = () => resultType,
        GetRows = () =>
            let
                data = executeQuery(query, context),
                oldNames = Table.ColumnNames(data),
                newNames = Table.ColumnNames(#table(resultType, {})),
                pairs = List.Zip({oldNames, newNames}),
                renamed = try Table.RenameColumns(data, pairs, MissingField.Ignore) otherwise data,
                projected = Table.SelectColumns(renamed, newNames, MissingField.Ignore)
            in projected,
        ThrowFoldingFailures = false
    ]);

// ============================================================================
// NAVIGATION: Databases > Schemas > Tables
// ============================================================================
MakeNavTableType = (isLeaf as logical) as type =>
    let
        dataType = type table meta [
            NavigationTable.ItemKind = "Table", Preview.Delay = "Table",
            NavigationTable.RowConfigurationColumn = "Kind"
        ],
        tableType = type table [Name = text, Description = nullable text, Data = dataType, Kind = text],
        withKeys = Type.ReplaceTableKeys(tableType, {[Columns = {"Name", "Kind"}, Primary = true]}) meta [
            NavigationTable.NameColumn = "Name", NavigationTable.DataColumn = "Data", NavigationTable.KindColumn = "Kind"
        ]
    in withKeys;

GetDatabases = (context as record, optional filterDatabase as text) =>
    let
        isLeaf = false, kind = "Database",
        command = "SHOW DATABASES",
        raw = context[ExecuteQuery](command, [IsMetadata = true]),
        tables = Table.RenameColumns(raw, {{"database_name", "Name"}}),
        filtered = if filterDatabase <> null then Table.SelectRows(tables, each [Name] = filterDatabase) else tables,
        getSchemas = (name) => GetSchemas(context, name),
        withDescription = Table.AddColumn(filtered, "Description", each null, type nullable text),
        withData = Table.AddColumn(withDescription, "Data", each getSchemas([Name]), type table),
        withKind = Table.AddColumn(withData, "Kind", each kind meta [NavigationTable.IsLeaf = isLeaf], type text),
        withFolding = Table.View(null, [
            GetType = () => MakeNavTableType(isLeaf), GetRows = () => withKind,
            OnSelectRows = (selector) => FoldNavigationStep(withKind, selector, getSchemas, kind),
            ThrowFoldingFailures = false
        ])
    in withFolding;

GetSchemas = (context as record, catalog as text) =>
    let
        isLeaf = false, kind = "Schema",
        command = "SELECT schema_name AS Name FROM information_schema.schemata WHERE catalog_name = "
            & EscapeString(catalog) & " AND schema_name <> 'information_schema'",
        schemas = context[ExecuteQuery](command, [IsMetadata = true]),
        getTables = (name) => GetTables(context, catalog, name),
        withDescription = Table.AddColumn(schemas, "Description", each null, type nullable text),
        withData = Table.AddColumn(withDescription, "Data", each getTables([Name]), type table),
        withKind = Table.AddColumn(withData, "Kind", each kind meta [NavigationTable.IsLeaf = isLeaf], type text),
        withFolding = Table.View(null, [
            GetType = () => MakeNavTableType(isLeaf), GetRows = () => withKind,
            OnSelectRows = (selector) => FoldNavigationStep(withKind, selector, getTables, kind),
            OnNativeQuery = (cmd, params, opts) => try NativeQuery(context, catalog, cmd) catch (e) => error Table.ViewError(e),
            ThrowFoldingFailures = false
        ])
    in withFolding;

GetTables = (context as record, catalog as text, schema as text) =>
    let
        isLeaf = true, kind = {"Table", "View"},
        command = Text.Combine({
            "SELECT table_name AS Name, table_type FROM information_schema.tables WHERE table_catalog = ",
            EscapeString(catalog), " AND table_schema = ", EscapeString(schema)
        }),
        tables = context[ExecuteQuery](command, [IsMetadata = true]),
        getTable = (name) => GetTable(context, catalog, schema, name),
        withDescription = Table.AddColumn(tables, "Description", each null, type nullable text),
        withData = Table.AddColumn(withDescription, "Data", each getTable([Name]), type table),
        withKind = Table.AddColumn(withData, "Kind",
            each (if [table_type] = "VIEW" then "View" else "Table") meta [NavigationTable.IsLeaf = isLeaf], type text),
        removeType = Table.RemoveColumns(withKind, {"table_type"}),
        withFolding = Table.View(null, [
            GetType = () => MakeNavTableType(isLeaf), GetRows = () => removeType,
            OnSelectRows = (selector) => FoldNavigationStep(removeType, selector, getTable, "Table"),
            ThrowFoldingFailures = false
        ])
    in withFolding;

GetTable = (context as record, catalog as text, schema as text, table as text) =>
    let
        tableType = GetTableType(context, catalog, schema, table),
        tableReference = [Kind = "FromTable", Table = [Schema = schema, Name = table]],
        withSqlView = context[SqlGenerator](tableReference, tableType, []),
        // Transform nested columns (STRUCT, ARRAY) from text to native M types.
        // DuckDB's ADBC driver delivers these as native Arrow list/struct, so values
        // are already M list/record — we just re-type the columns to `type any`.
        rowFields = Type.RecordFields(Type.TableRow(tableType)),
        columnNames = Record.FieldNames(rowFields),
        nestedColumns = List.Select(columnNames, (col) =>
            let
                colType = Record.Field(rowFields, col)[Type],
                nativeName = Record.FieldOrDefault(Type.Facets(colType), "NativeTypeName", null)
            in
                nativeName = "STRUCT" or nativeName = "ARRAY"
        ),
        withNestedTypes = if List.Count(nestedColumns) > 0
            then Table.TransformColumnTypes(withSqlView, List.Transform(nestedColumns, each {_, type any}))
            else withSqlView
    in withNestedTypes;

GetTableType = (context as record, catalog as text, schema as text, table as text) =>
    let
        command = Text.Combine({
            "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_catalog = ",
            EscapeString(catalog), " AND table_schema = ", EscapeString(schema),
            " AND table_name = ", EscapeString(table), " ORDER BY ordinal_position"
        }),
        columns = Table.Buffer(context[ExecuteQuery](command, [IsMetadata = true])),
        withType = Table.AddColumn(columns, "Type",
            each [Type = GetColumnType([data_type], [is_nullable]), Optional = false]),
        rowType = Type.ForRecord(Record.FromList(withType[Type], withType[column_name]), false),
        tableType = type table rowType,
        withPrimaryKeys = ApplyPrimaryKeys(context, catalog, schema, table, tableType)
    in withPrimaryKeys;

GetColumnType = (typeName as text, isNullable as text) =>
    let
        baseType = if Text.EndsWith(typeName, "[]") then "ARRAY"
            else if Text.Contains(typeName, "(") then Text.BeforeDelimiter(typeName, "(")
            else typeName,
        normalized = Text.Upper(Text.Trim(baseType)),
        matchedType = Record.FieldOrDefault(DuckDbSqlGenerator[TypeFacets], normalized, null),
        mtype = if matchedType <> null then matchedType else type any
    in if isNullable = "YES" then type nullable mtype else mtype;

// ============================================================================
// PRIMARY & FOREIGN KEY RELATIONSHIPS
// ============================================================================
ApplyPrimaryKeys = (context as record, catalog as text, schema as text, table as text, tableType as type) as type =>
    let
        pkCommand = Text.Combine({
            "SELECT kcu.column_name ",
            "FROM information_schema.table_constraints tc ",
            "JOIN information_schema.key_column_usage kcu ",
            "  ON tc.constraint_name = kcu.constraint_name ",
            "  AND tc.table_catalog = kcu.table_catalog ",
            "  AND tc.table_schema = kcu.table_schema ",
            "  AND tc.table_name = kcu.table_name ",
            "WHERE tc.constraint_type = 'PRIMARY KEY' ",
            "  AND tc.table_catalog = ", EscapeString(catalog),
            "  AND tc.table_schema = ", EscapeString(schema),
            "  AND tc.table_name = ", EscapeString(table),
            " ORDER BY kcu.ordinal_position"
        }),
        pkResult = try context[ExecuteQuery](pkCommand, [IsMetadata = true]) otherwise #table({"column_name"}, {}),
        pkColumns = pkResult[column_name],
        hasPK = List.Count(pkColumns) > 0,
        withPK = if hasPK then Type.ReplaceTableKeys(tableType, {[Columns = pkColumns, Primary = true]}) else tableType
    in withPK;

GetForeignKeys = (context as record, catalog as text, schema as text, table as text) as table =>
    let
        fkCommand = Text.Combine({
            "SELECT kcu.column_name AS from_column, ccu.table_schema AS to_schema, ",
            "  ccu.table_name AS to_table, ccu.column_name AS to_column ",
            "FROM information_schema.table_constraints tc ",
            "JOIN information_schema.key_column_usage kcu ",
            "  ON tc.constraint_name = kcu.constraint_name AND tc.table_catalog = kcu.table_catalog ",
            "  AND tc.table_schema = kcu.table_schema AND tc.table_name = kcu.table_name ",
            "JOIN information_schema.constraint_column_usage ccu ",
            "  ON tc.constraint_name = ccu.constraint_name AND tc.table_catalog = ccu.table_catalog ",
            "WHERE tc.constraint_type = 'FOREIGN KEY' ",
            "  AND tc.table_catalog = ", EscapeString(catalog),
            "  AND tc.table_schema = ", EscapeString(schema),
            "  AND tc.table_name = ", EscapeString(table)
        }),
        fkResult = try context[ExecuteQuery](fkCommand, [IsMetadata = true])
            otherwise #table({"from_column", "to_schema", "to_table", "to_column"}, {})
    in fkResult;

// ============================================================================
// NATIVE QUERY SUPPORT
// ============================================================================
NativeQuery = (context as record, catalog as text, cmd as text) =>
    let
        typeQuery = "SELECT * FROM (" & cmd & ") AS ""_"" WHERE 0 = 1",
        typeResult = context[ExecuteQuery](typeQuery, []),
        tableType = Value.Type(Table.Buffer(typeResult)),
        reference = [Kind = "FromQuery", Query = [Kind = "Verbatim", Query = cmd], Alias = "_"],
        result = context[SqlGenerator](reference, tableType, [])
    in result;

// ============================================================================
// HELPERS
// ============================================================================
EscapeIdentifier = (identifier as text) as text => """" & Text.Replace(identifier, """", """""") & """";
EscapeString = (string as text) as text => "'" & Text.Replace(string, "'", "''") & "'";

FoldNavigationStep = (base as table, selector as function, loader as function, kind as any) =>
    let
        reduceAnd = (ast) => if ast[Kind] = "Binary" and ast[Operator] = "And" then List.Combine({@reduceAnd(ast[Left]), @reduceAnd(ast[Right])}) else {ast},
        matchFieldAccess = (ast) => if ast[Kind] = "FieldAccess" and ast[Expression] = RowExpression.Row then ast[MemberName] else ...,
        matchConstant = (ast) => if ast[Kind] = "Constant" then ast[Value] else ...,
        matchIndex = (ast) => if ast[Kind] = "Binary" and ast[Operator] = "Equals" then
            if ast[Left][Kind] = "FieldAccess" then Record.AddField([], matchFieldAccess(ast[Left]), matchConstant(ast[Right]))
            else Record.AddField([], matchFieldAccess(ast[Right]), matchConstant(ast[Left]))
        else ...,
        predicate1 = Record.Combine(List.Transform(reduceAnd(RowExpression.From(selector)), matchIndex)),
        isKindList = kind is list,
        kindMatch = if isKindList then List.Contains(kind, predicate1[Kind]?) else predicate1[Kind]? = kind,
        predicate2 = if kindMatch then Record.RemoveFields(predicate1, {"Kind"}) else predicate1,
        name = if Record.FieldCount(predicate2) = 1 and predicate2[Name]? <> null then predicate2[Name] else ...,
        success = not (try name)[HasError]
    in
        if success then Table.FromRecords({[Name = name, Description = "", Data = loader(name), Kind = kind]})
        else Table.SelectRows(base, selector);

// ============================================================================
// EXTENSION LOADERS
// ============================================================================
Extension.LoadExpression = (name as text) =>
    let binary = Extension.Contents(name), asText = Text.FromBinary(binary)
    in Expression.Evaluate(asText, #shared);

// ============================================================================
// DATA SOURCE AND PUBLISH CONFIGURATION
// ============================================================================
DuckDb = [
    Type = "Custom",
    // Resource path format: "server;encryption" or "server;encryption;database"
    MakeResourcePath = (server, encryption, optional database) =>
        let
            base = server & ";" & encryption
        in
            if database <> null then base & ";" & database else base,
    ParseResourcePath = (resourcePath as text) =>
        let
            parts = Text.Split(resourcePath, ";"),
            server = parts{0},
            encryption = if List.Count(parts) > 1 then parts{1} else "Enabled",
            database = if List.Count(parts) > 2 then parts{2} else null
        in
            {server, encryption, database},
    TestConnection = (resourcePath as text) =>
        let
            parts = Text.Split(resourcePath, ";"),
            server = parts{0},
            encryption = if List.Count(parts) > 1 then parts{1} else "Enabled",
            database = if List.Count(parts) > 2 then parts{2} else null
        in
            {"DuckDb.Contents", server, encryption, database},
    Authentication = [
        UsernamePassword = [Name = "DuckDb", Label = "Username & Password"],
        Key = [Label = "API Key / Bearer Token", KeyLabel = "Token"],
        Anonymous = []
    ],
    // Encryption is handled by the connector's own Encryption parameter, not by SupportsEncryption
    SupportsEncryption = false
];

DuckDb.Publish = [
    Beta = true, Category = "Database", SupportsDirectQuery = true,
    NativeQueryProperties = [navigationSteps = {[]}, nativeQueryOptions = [EnableFolding = true]],
    ButtonText = {"DuckDb (FlightSQL)", "Connect to DuckDb via FlightSQL"},
    SourceImage = null, SourceTypeImage = null
];

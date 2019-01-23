section RedshiftODBC;

// When set to true, additional trace information will be written out to the User log. 
// This should be set to false before release. Tracing is done through a call to 
// Diagnostics.LogValue(). When EnableTraceOutput is set to false, the call becomes a 
// no-op and simply returns the original value.
EnableTraceOutput = true;

Config_DriverName = "Amazon Redshift (x86)";
Config_SqlConformance = ODBC[SQL_SC][SQL_SC_SQL92_FULL];  // null, 1, 2, 4, 8
Config_DefaultUsernamePasswordHandling = true;  // true, false
Config_UseParameterBindings = true;  // true, false, null
Config_StringLiterateEscapeCharacters  = { "\" }; // ex. { "\" }
Config_UseCastInsteadOfConvert = true; // true, false, null
Config_SupportsTop = true; // true, false
Config_EnableDirectQuery = true;    // true, false

// This is a work around for the lack of available conversion functions in the driver.
ImplicitTypeConversions = #table(
    { "Type1",        "Type2",         "ResultType" }, {
    // 'bpchar' char is added here to allow it to be converted to 'char' when compared against constants.
    { "bpchar",       "char",          "char" }
});

[DataSource.Kind="RedshiftODBC", Publish="RedshiftODBC.UI"]
shared RedshiftODBC.Database = (server as text, database as text, optional options as record) as table =>
    let
        ConnectionString = GetAddress(server) & [
            Driver = Config_DriverName,
            UseUnicode = "yes",
            Database = database
        ],

        Credential = Extension.CurrentCredential(),
        encryptionEnabled = Credential[EncryptConnection]? = true,
		CredentialConnectionString = [
            SSLMode = if encryptionEnabled then "verify-full" else "prefer",
            UID = Credential[Username],
            PWD = Credential[Password],
            BoolsAsChar = 0,
            MaxVarchar = 65535
        ],
        
        defaultConfig = BuildOdbcConfig(),

        SqlCapabilities = defaultConfig[SqlCapabilities] & [
            // place custom overrides here
            GroupByCapabilities = ODBC[SQL_GB][SQL_GB_NO_RELATION],
            FractionalSecondsScale = 3
        ],

        SQLGetInfo = defaultConfig[SQLGetInfo] & [

        ],

        SQLGetTypeInfo = (types) => 
            let
                original =
                    if (EnableTraceOutput <> true) then
                        types 
                    else
                        let 
                            // Outputting the entire table might be too large, and result in the value being truncated.
                            // We can output a row at a time instead with Table.TransformRows()
                            rows = Table.TransformRows(types, each Diagnostics.LogValue("SQLGetTypeInfo " & _[TYPE_NAME], _)),
                            toTable = Table.FromRecords(rows)
                        in
                            toTable,
                modified = 
                    // older versions of the driver were missing an entry for 'bpchar'
                    if (Table.IsEmpty(Table.SelectRows(original, each [TYPE_NAME] = "bpchar"))) then 
                        let
                            // add the missing bpchar type by copying the 'char' entry and modifying the relevant values
                            charRecord = original{[TYPE_NAME="char",DATA_TYPE=-8]},
                            bpChar = charRecord & [TYPE_NAME = "bpchar",LOCAL_TYPE_NAME = "bpchar"],
                            finalTable = original & Table.FromRecords({bpChar})
                        in
                            finalTable
                    else
                        original
            in
                Value.ReplaceType(modified, Value.Type(types)),

        SQLColumns = (catalogName, schemaName, tableName, columnName, source) =>
            if (EnableTraceOutput <> true) then source else
            // the if statement conditions will force the values to evaluated/written to diagnostics
            if (Diagnostics.LogValue("SQLColumns.TableName", tableName) <> "***" and Diagnostics.LogValue("SQLColumns.ColumnName", columnName) <> "***") then
                let
                    // Outputting the entire table might be too large, and result in the value being truncated.
                    // We can output a row at a time instead with Table.TransformRows()
                    rows = Table.TransformRows(source, each Diagnostics.LogValue("SQLColumns", _)),
                    toTable = Table.FromRecords(rows)
                in
                    Value.ReplaceType(toTable, Value.Type(source))
            else
                source,

        OnError = (errorRecord as record) =>
            if Text.Contains(errorRecord[Message], "password authentication failed") then
                error Extension.CredentialError(Credential.AccessDenied, errorRecord[Message])
            else if encryptionEnabled and Text.Contains(errorRecord[Message], "root.crt"" does not exist") then
                error Extension.CredentialError(Credential.EncryptionNotSupported, errorRecord[Message])
            else 
                error errorRecord,

        AstVisitor = [
            // Decimal literals are always of type "numeric" which prevents high range numbers to be used.
            // We therefore wrap float4 and float8 with CAST for that purpose.
            Constant =
                let
                    Cast = (value, typeName) => [
                        Text = Text.Format("CAST(#{0} as #{1})", { value, typeName })
                    ],
                    Visitor = [
                        float8 = each Cast(_, "float8"),
                        float4 = each Cast(_, "float4")
                    ]
                in
                    (typeInfo, ast) => Record.FieldOrDefault(Visitor, typeInfo[TYPE_NAME], each null)(ast[Value])
        ],

        OdbcDatasource = Odbc.DataSource(ConnectionString, [
            HierarchicalNavigation = true, 
            HideNativeQuery = true,
            ClientConnectionPooling = true,

            ImplicitTypeConversions = ImplicitTypeConversions,
            OnError = OnError,

            // These values should be set by previous steps
            CredentialConnectionString = CredentialConnectionString,
            AstVisitor = AstVisitor,
            SqlCapabilities = SqlCapabilities,
            SQLColumns = SQLColumns,
            SQLGetInfo = SQLGetInfo,
            SQLGetTypeInfo = SQLGetTypeInfo
        ]),

        Database = OdbcDatasource{[Name = database]}[Data],
        RemovedSystemTable = Table.SelectRows(Database, each [Name] <> "pg_internal"), // non-queryable system table
        FixNestedNavigationTables =
            let
                ColumnType = Type.TableColumn(Value.Type(RemovedSystemTable), "Data"),
                AddColumn = Table.AddColumn(RemovedSystemTable, "Data2", each FixNavigationTable([Data]), ColumnType),
                RemovePreviousColumn = Table.RemoveColumns(AddColumn, { "Data" }),
                RenameColumn = Table.RenameColumns(RemovePreviousColumn, { { "Data2", "Data" } })
            in
                RenameColumn,
        Fixed = FixNavigationTable(FixNestedNavigationTables)
    in
        Fixed;

GetAddress = (server as text) as record =>
    let
        Address = Uri.Parts("http://" & server),
        Port = if Address[Port] = 80 and not Text.EndsWith(server, ":80") then [] else [Port = Address[Port]],
        Server = [Server = Address[Host]],
        ConnectionString = Server & Port,
        Result =
            if Address[Host] = ""
                or Address[Scheme] <> "http"
                or Address[Path] <> "/"
                or Address[Query] <> []
                or Address[Fragment] <> ""
                or Address[UserName] <> ""
                or Address[Password] <> ""
                or Text.StartsWith(server, "http:/", Comparer.OrdinalIgnoreCase) then
                error "Invalid server name"
            else
                ConnectionString
    in
        Result;

// Fixes navigation table return from ODBC hierarchical navigation
// to not have Kind as part of the key and to remove columns that return
// not value for this ODBC driver such as "Description".
FixNavigationTable = (table) =>
    let
        SelectColumns = Table.SelectColumns(table, { "Name", "Data", "Kind" }),
        OriginalType = Value.Type(SelectColumns),
        Type = type table [
            Name = Type.TableColumn(OriginalType, "Name"),
            Data = Type.TableColumn(OriginalType, "Data"),
            Kind = Type.TableColumn(OriginalType, "Kind")
        ],
        AddKey = Type.AddTableKey(Type, { "Name" }, true),
        AddMetadata = AddKey meta [
            NavigationTable.NameColumn = "Name",
            NavigationTable.DataColumn = "Data",
            NavigationTable.KindColumn = "Kind",
            Preview.DelayColumn = "Data"
        ],
        ReplaceType = Value.ReplaceType(SelectColumns, AddMetadata)
    in
        ReplaceType;

RedshiftODBC = [
    TestConnection = (dataSourcePath) => 
        let
            json = Json.Document(dataSourcePath),
            server = json[server],
            database = json[database]
        in
            { "RedshiftODBC.Database", server, database },
    Authentication = [
        UsernamePassword = [
        ]
    ],
    SupportsEncryption = true
];

RedshiftODBC.UI = [
    ButtonText = { "RedshiftODBC Sample", "RedshiftODBC Sample" },
    Category = "Database",
    SupportsDirectQuery = true
];

// build settings based on configuration variables
BuildOdbcConfig = () as record =>
    let        
        defaultConfig = [
            SqlCapabilities = [],
            SQLGetFunctions = [],
            SQLGetInfo = []
        ],

        withParams =
            if (Config_UseParameterBindings = false) then
                let 
                    caps = defaultConfig[SqlCapabilities] & [ 
                        SqlCapabilities = [
                            SupportsNumericLiterals = true,
                            SupportsStringLiterals = true,                
                            SupportsOdbcDateLiterals = true,
                            SupportsOdbcTimeLiterals = true,
                            SupportsOdbcTimestampLiterals = true
                        ]
                    ],
                    funcs = defaultConfig[SQLGetFunctions] & [
                        SQLGetFunctions = [
                            SQL_API_SQLBINDPARAMETER = false
                        ]
                    ]
                in
                    defaultConfig & caps & funcs
            else
                defaultConfig,
                
        withEscape = 
            if (Config_StringLiterateEscapeCharacters <> null) then 
                let
                    caps = withParams[SqlCapabilities] & [ 
                        SqlCapabilities = [
                            StringLiteralEscapeCharacters = Config_StringLiterateEscapeCharacters
                        ]
                    ]
                in
                    withParams & caps
            else
                withParams,

        withTop =
            let
                caps = withEscape[SqlCapabilities] & [ 
                    SqlCapabilities = [
                        SupportsTop = Config_SupportsTop
                    ]
                ]
            in
                withEscape & caps,

        withCastOrConvert = 
            if (Config_UseCastInsteadOfConvert = true) then
                let
                    caps = withTop[SQLGetFunctions] & [ 
                        SQLGetFunctions = [
                            SQL_CONVERT_FUNCTIONS = 0x2 /* SQL_FN_CVT_CAST */
                        ]
                    ]
                in
                    withTop & caps
            else
                withTop,

        withSqlConformance =
            if (Config_SqlConformance <> null) then
                let
                    caps = withCastOrConvert[SQLGetInfo] & [
                        SQLGetInfo = [
                            SQL_SQL_CONFORMANCE = Config_SqlConformance
                        ]
                    ]
                in
                    withCastOrConvert & caps
            else
                withCastOrConvert
    in
        withSqlConformance;

// 
// Load common library functions
// 
Extension.LoadFunction = (name as text) =>
    let
        binary = Extension.Contents(name),
        asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

// Diagnostics module contains multiple functions. We can take the ones we need.
Diagnostics = Extension.LoadFunction("Diagnostics.pqm");
Diagnostics.LogValue = if (EnableTraceOutput) then Diagnostics[LogValue] else (prefix, value) => value;

// OdbcConstants contains numeric constants from the ODBC header files, and a 
// helper function to create bitfield values.
ODBC = Extension.LoadFunction("OdbcConstants.pqm");
Odbc.Flags = ODBC[Flags];
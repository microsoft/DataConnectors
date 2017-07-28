section ImpalaODBC;

DefaultPort = 21050;
AnonymousAuthMech = 0;
UsernamePasswordAuthMech = 3;

[DataSource.Kind="ImpalaODBC", Publish="ImpalaODBC.UI"]
shared ImpalaODBC.Databases = (server as text, optional options as record) as table =>
    let
        Address = GetAddress(server),
        HostAddress = Address[Host],
        HostPort = Address[Port],
        ConnectionString = [
            Driver = "Cloudera Impala ODBC Driver",
            Host = HostAddress,
            Port = HostPort,
            // We need a database name that doesn't exist in the server, because if the user doesn't have access to
            // "default", it throws an exception. Specifying a DB that doesn't exist works fine, though.
            Database = "DoesNotExist9A8CF2764FB34AECA572E2789EB6B2A2",
            UseUnicodeSqlCharacterTypes = 1
        ],

        Credential = Extension.CurrentCredential(),
        RequireEncryption = if Credential[EncryptConnection]? = null
            then 1
            else if Credential[EncryptConnection] = true
                then 1 
                else 0,
        CredentialConnectionString = if Credential[AuthenticationKind]? = "UsernamePassword" then [
                UID = Credential[Username], 
                PWD = Credential[Password], 
                AuthMech = UsernamePasswordAuthMech]
            else [AuthMech = AnonymousAuthMech],
        CommonOptions = [
            CredentialConnectionString = CredentialConnectionString & [SSL = RequireEncryption],
            ClientConnectionPooling = true,
            OnError = OnError
        ],
        OdbcDatasource = Odbc.DataSource(ConnectionString, [
            HierarchicalNavigation = true,
            TolerateConcatOverflow = true,
            SqlCapabilities = [
                SupportsTop = true,
                Sql92Conformance = 8,
                SupportsNumericLiterals = true,
                SupportsStringLiterals = true,
                SupportsOdbcDateLiterals = true,
                SupportsOdbcTimeLiterals = true,
                SupportsOdbcTimestampLiterals = true
            ],
            SQLGetFunctions = [
                // Disable using parameters in the queries that get generated.
                // We enable numeric and string literals which should enable literals for all constants.
                SQL_API_SQLBINDPARAMETER = false
            ]
        ] & CommonOptions),
            
        ComplexColumnsRemoved = RemoveComplexColumnsFromNavigation(OdbcDatasource{[Name="IMPALA",Kind="Database"]}[Data])
    in
        ComplexColumnsRemoved;

RemoveComplexColumns = (data as table) as table =>
    let
        SchemaTable = Table.Schema(data),
        ComplexColumnNames = Table.SelectRows(SchemaTable, each Text.Contains([NativeTypeName], "<"))[Name],
        ComplexColumnsRemoved = 
            if List.Count(ComplexColumnNames) = Table.RowCount(SchemaTable) then 
                error [Reason = "DataSource.Error", Message = "No Scalar Columns available"]
            else Table.RemoveColumns(data, ComplexColumnNames)
    in
        ComplexColumnsRemoved;
            
RemoveComplexColumnsFromNavigation = (source as table) as table =>
    let
        TableLevelNavigationTableType = Value.Type(source{0}[Data]),
        TransformedTable = Table.TransformColumns(source,{{
            "Data", 
            (data) => Value.ReplaceType(
                Table.TransformColumns(data, {{"Data", (rawTable) => RemoveComplexColumns(rawTable)}}),
                TableLevelNavigationTableType)}})
    in
        Value.ReplaceType(TransformedTable, Value.Type(source));

OnError = (errorRecord as record) =>
    let
        OdbcError = errorRecord[Detail][OdbcErrors]{0},
        OdbcErrorMessage = OdbcError[Message],
        OdbcErrorCode = OdbcError[NativeError],
        HasCredentialError = errorRecord[Detail] <> null
            and errorRecord[Detail][OdbcErrors]? <> null
            and Text.Contains(OdbcErrorMessage, "[ThriftExtension]")
            and OdbcErrorCode <> 0 and OdbcErrorCode <> 7,
        IsSSLError = OdbcErrorCode = 6
    in
        if HasCredentialError then
            if IsSSLError then 
                error Extension.CredentialError(Credential.EncryptionNotSupported)
            else 
                error Extension.CredentialError(Credential.AccessDenied, OdbcErrorMessage)
        else 
            error errorRecord;

GetAddress = (server as text) as record =>
    let
        Address = Uri.Parts("http://" & server),
        BadServer = Address[Host] = "" or Address[Scheme] <> "http" or Address[Path] <> "/" or Address[Query] <> [] or Address[Fragment] <> ""
            or Address[UserName] <> "" or Address[Password] <> "",
        Port = if Address[Port] = 80 and not Text.EndsWith(server, ":80") then 
                DefaultPort 
            else Address[Port],
        Host = Address[Host],
        Result = [Host=Host, Port=Port]
    in
        if BadServer then 
            error "Invalid server name"
        else Result;

ImpalaODBC = [
    Authentication = [
        UsernamePassword = [],
        Implicit = []
    ],
    SupportsEncryption = true
];

ImpalaODBC.UI = [
    Beta = true,
    Category = "Database",
    ButtonText = { "ImpalaODBC Sample", "ImpalaODBC Sample" },
    SupportsDirectQuery = true
];
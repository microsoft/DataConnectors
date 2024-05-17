[Version = "1.0.0"]
section ImpalaODBC;

DefaultPort = 21050;

[DataSource.Kind = "ImpalaODBC", Publish = "ImpalaODBC.UI"]
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
        CommonOptions = [
            CredentialConnectionString = GetCredentialConnectionString(),
            ClientConnectionPooling = true,
            OnError = OnError
        ],
        OdbcDatasource = Odbc.DataSource(
            ConnectionString,
            [
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
            ]
                & CommonOptions
        ),
        ComplexColumnsRemoved = RemoveComplexColumnsFromNavigation(
            OdbcDatasource{[Name = "IMPALA", Kind = "Database"]}[Data]
        )
    in
        ComplexColumnsRemoved;

// Sets the connection string properties related to authentication.
// The set of connection string properties will vary between drivers.
// Please check the ODBC driver's documentation for the exact properties to use.
// For Impala, we set:
//   AuthMech: integer value indicating the auth type (Anonymous, Kerberos/Windows, UsernamePassword)
//   UID: user ID (when using UsernamePassword auth)
//   PWD: password (when using UsernamePassword auth)
//   UseOnlySSPI: bool (1/0) required when using Kerberos/Windows auth
//   SSL: bool (1/0) indicating whether to connect using SSL
//   UseSystemTrustStore: bool (1/0) should match the value for SSL
GetCredentialConnectionString = () as record =>
    let
        Credential = Extension.CurrentCredential(),
        AuthKind = Credential[AuthenticationKind],
        AuthMech.Anonymous = 0,
        AuthMech.Kerberos = 1,
        AuthMech.UsernamePassword = 3,
        ConnectionString =
            if AuthKind = "Implicit" or AuthKind = "Anonymous" then
                [AuthMech = AuthMech.Anonymous]
            else if AuthKind = "Windows" then
                [
                    AuthMech = AuthMech.Kerberos,
                    UseOnlySSPI = 1
                ]
            else if AuthKind = "UsernamePassword" then
                [
                    AuthMech = AuthMech.UsernamePassword,
                    UID = Credential[Username],
                    PWD = Credential[Password]
                ]
            else
                // Unknown/unexpected auth kind, return "not implemented" as an error
                ...,
        // This logic is for data sources that optional SSL/encrypted connections.
        // When SupportsEncryption is set to true on the data source kind record,
        // Power Query will try to connect using SSL. If that fails, the connector
        // should return Extension.CredentialError(Credential.EncryptionNotSupported)
        // to indicate that encryption isn't enabled for this source. If the user then
        // chooses to establish an unencrypted connection, Credential[EncryptConnection]
        // will be set to false on the subsequent connection attempt.
        EncryptConnection = Credential[EncryptConnection]?,
        SSL = if EncryptConnection = null or EncryptConnection = true then 1 else 0
    in
        ConnectionString & [SSL = SSL, UseSystemTrustStore = SSL];

RemoveComplexColumns = (data as table) as table =>
    let
        SchemaTable = Table.Schema(data),
        ComplexColumnNames = Table.SelectRows(SchemaTable, each Text.Contains([NativeTypeName], "<"))[Name],
        ComplexColumnsRemoved =
            if List.Count(ComplexColumnNames) = Table.RowCount(SchemaTable) then
                error [Reason = "DataSource.Error", Message = "No Scalar Columns available"]
            else
                Table.RemoveColumns(data, ComplexColumnNames)
    in
        ComplexColumnsRemoved;

RemoveComplexColumnsFromNavigation = (source as table) as table =>
    let
        TableLevelNavigationTableType = Value.Type(source{0}[Data]),
        TransformedTable = Table.TransformColumns(
            source,
            {
                {
                    "Data",
                    (data) =>
                        Value.ReplaceType(
                            Table.TransformColumns(data, {{"Data", (rawTable) => RemoveComplexColumns(rawTable)}}),
                            TableLevelNavigationTableType
                        )
                }
            }
        )
    in
        Value.ReplaceType(TransformedTable, Value.Type(source));

OnError = (errorRecord as record) =>
    let
        OdbcError = errorRecord[Detail][OdbcErrors]{0},
        OdbcErrorMessage = OdbcError[Message],
        OdbcErrorCode = OdbcError[NativeError],
        HasCredentialError =
            errorRecord[Detail] <> null
            and errorRecord[Detail][OdbcErrors]? <> null
            and Text.Contains(OdbcErrorMessage, "[ThriftExtension]")
            and OdbcErrorCode <> 0
            and OdbcErrorCode <> 7,
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
        BadServer =
            Address[Host] = ""
            or Address[Scheme] <> "http"
            or Address[Path] <> "/"
            or Address[Query] <> []
            or Address[Fragment] <> ""
            or Address[UserName] <> ""
            or Address[Password] <> "",
        Port = if Address[Port] = 80 and not Text.EndsWith(server, ":80") then DefaultPort else Address[Port],
        Host = Address[Host],
        Result = [Host = Host, Port = Port]
    in
        if BadServer then
            error "Invalid server name"
        else
            Result;

ImpalaODBC = [
    Authentication = [
        Anonymous = [],
        UsernamePassword = [],
        Windows = [SupportsAlternateCredentials = true]
    ],
    // Indicate optional SSL requirement
    SupportsEncryption = true
];

ImpalaODBC.UI = [
    Beta = true,
    Category = "Database",
    ButtonText = {"ImpalaODBC Sample", "ImpalaODBC Sample"},
    SupportsDirectQuery = true
];

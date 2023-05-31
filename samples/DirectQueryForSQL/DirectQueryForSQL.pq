section DirectSQL;

[DataSource.Kind = "DirectSQL", Publish = "DirectSQL.UI"]
shared DirectSQL.Database = (server as text, database as text) as table =>
    let
        // This record contains all of the connection string properties we
        // will set for this ODBC driver. The 'Driver' field is required for
        // all ODBC connections. Other properties will vary between ODBC drivers,
        // but generally take Server and Database properties. Note that
        // credential related properties will be set separately.
        ConnectionString = [
            Driver = "SQL Server Native Client 11.0",
            Server = server,
            Database = database
        ],
        // Get the current credential, and check what type of authentication we're using
        Credential = Extension.CurrentCredential(),
        // Credentials are passed to the ODBC driver using the CredentialConnectionString field.
        // If the user has selected SQL auth (i.e. UsernamePassword), we'll set the
        // UID and PWD connection string properties. This should be standard across ODBC drivers.
        // If the user has selected Windows auth, we'll set the Trusted_Connection property.
        // Trusted_Connection is specific to the SQL Server Native Client ODBC driver.
        // Other drivers might require additional connection string properties to be set.
        CredentialConnectionString =
            if (Credential[AuthenticationKind]?) = "UsernamePassword" then
                [UID = Credential[Username], PWD = Credential[Password]]
            else if (Credential[AuthenticationKind]?) = "Windows" then
                [Trusted_Connection = "Yes"]
                // unknown authentication kind - return an 'unimplemented' error
            else
                ...,
        // Here our connector is wrapping M's Odbc.DataSource() function.
        //
        // The first argument will be the connection string. It can be passed in as a record,
        // or an actual text value. When using a record, M will ensure that the values will be
        // property encoded.
        //
        // The second argument is the options record which allows us to set the credential
        // connection string properties, and override default behaviors.
        OdbcDataSource = Odbc.DataSource(
            ConnectionString,
            [
                // Pass the credential-specific part of the connection string
                CredentialConnectionString = CredentialConnectionString,
                // Enables client side connection pooling for the ODBC driver.
                // Most drivers will want to set this value to true.
                ClientConnectionPooling = true,
                // When HierarchialNavigation is set to true, the navigation tree
                // will be organized by Database -> Schema -> Table. When set to false,
                // all tables will be displayed in a flat list using fully qualified names.
                HierarchicalNavigation = true,
                // Use the SqlCapabilities record to specify driver capabilities that are not
                // discoverable through ODBC 3.8, and to override capabilities reported by
                // the driver.
                SqlCapabilities = [
                    SupportsTop = true,
                    Sql92Conformance = 8 /* SQL_SC_SQL92_FULL */,
                    GroupByCapabilities = 4 /* SQL_GB_NO_RELATION */,
                    FractionalSecondsScale = 3
                ],
                SoftNumbers = true,
                HideNativeQuery = true,
                // Use the SQLGetInfo record to override values returned by the driver.
                SQLGetInfo = [
                    SQL_SQL92_PREDICATES = 0x0000FFFF,
                    SQL_AGGREGATE_FUNCTIONS = 0xFF
                ]
            ]
        ),
        // The first level of the navigation table will be the name of the database the user
        // passed in. Rather than repeating it again, we'll select it ({[Name = database]})
        // and access the next level of the navigation table.
        Database = OdbcDataSource{[Name = database]}[Data]
    in
        Database;

// Data Source definition
DirectSQL = [
    TestConnection = (dataSourcePath) =>
        let
            json = Json.Document(dataSourcePath), server = json[server], database = json[database]
        in
            {"DirectSQL.Database", server, database},
    Authentication = [
        Windows = [],
        UsernamePassword = []
    ],
    Label = "Direct Query for SQL",
    // This sample doesn't enable the use of SSL.
    SupportsEncryption = false
];

// UI Export definition
DirectSQL.UI = [
    // enables direct query
    SupportsDirectQuery = true,
    Category = "Database",
    ButtonText = {"Direct Query for SQL", "Direct Query via ODBC sample for SQL Server"},
    SourceImage = DirectSQL.Icons,
    SourceTypeImage = DirectSQL.Icons
];

DirectSQL.Icons = [
    Icon16 = {
        Extension.Contents("DirectQueryForSQL16.png"),
        Extension.Contents("DirectQueryForSQL20.png"),
        Extension.Contents("DirectQueryForSQL24.png"),
        Extension.Contents("DirectQueryForSQL32.png")
    },
    Icon32 = {
        Extension.Contents("DirectQueryForSQL32.png"),
        Extension.Contents("DirectQueryForSQL40.png"),
        Extension.Contents("DirectQueryForSQL48.png"),
        Extension.Contents("DirectQueryForSQL64.png")
    }
];

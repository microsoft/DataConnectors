section DirectSQL;

[DataSource.Kind="DirectSQL", Publish="DirectSQL.UI"]
shared DirectSQL.Database = (server as text, database as text, optional options as record) as table =>
    let
        ConnectionString =
        [
            Server = server,
            Driver = "SQL Server Native Client 11.0",
            Database = database
        ],

        // Odbc.DataSource will automatically inherit the Windows Auth credential from the extension
        OdbcDataSource = Odbc.DataSource(ConnectionString, [
            ClientConnectionPooling = true,
            HierarchicalNavigation = true,
            SqlCapabilities = [
                SupportsTop = true,
                Sql92Conformance = 8 /* SQL_SC_SQL92_FULL */,
                GroupByCapabilities = 4 /* SQL_GB_NO_RELATION */,
                FractionalSecondsScale = 3
            ],
            SoftNumbers = true,
            HideNativeQuery = true,
            SQLGetInfo = [
                SQL_SQL92_PREDICATES = 0x0000FFFF,
                SQL_AGGREGATE_FUNCTIONS = 0xFF
            ]
        ]),
        Database = OdbcDataSource{[Name = database]}[Data]
    in
        Database;

// Data Source definition
DirectSQL = [
    Authentication = [
        Windows = []
    ],
    Label = "Direct Query for SQL",
    SupportsEncryption = false
];

// UI Export definition
DirectSQL.UI = [
    SupportsDirectQuery = true,
    Category = "Database",
    ButtonText = { "Direct Query for SQL", "Direct Query via ODBC sample for SQL Server" },
    SourceImage = DirectSQL.Icons,
    SourceTypeImage = DirectSQL.Icons
];

DirectSQL.Icons = [
    Icon16 = { Extension.Contents("DirectSQL_ODBC16.png"), Extension.Contents("DirectSQL_ODBC20.png"), Extension.Contents("DirectSQL_ODBC24.png"), Extension.Contents("DirectSQL_ODBC32.png") },
    Icon32 = { Extension.Contents("DirectSQL_ODBC32.png"), Extension.Contents("DirectSQL_ODBC40.png"), Extension.Contents("DirectSQL_ODBC48.png"), Extension.Contents("DirectSQL_ODBC64.png") }
];

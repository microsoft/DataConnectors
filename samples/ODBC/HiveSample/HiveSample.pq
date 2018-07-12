section HiveSample;

// When set to true, additional trace information will be written out to the User log. 
// This should be set to false before release. Tracing is done through a call to 
// Diagnostics.LogValue(). When EnableTraceOutput is set to false, the call becomes a 
// no-op and simply returns the original value.
EnableTraceOutput = false;

/****************************
 * ODBC Driver Configuration
 ****************************/

Config_DriverName = "Microsoft Hive ODBC Driver";
// Config_DriverName = "Hortonworks Hive ODBC Driver";

Config_SqlConformance = SQL_SC[SQL_SC_SQL92_FULL];  // null, 1, 2, 4, 8
Config_DefaultUsernamePasswordHandling = true;  // true, false
Config_UseParameterBindings = false;  // true, false, null
Config_StringLiterateEscapeCharacters  = { "\" }; // ex. { "\" }
Config_UseCastInsteadOfConvert = null; // true, false, null
Config_SupportsTop = false; // true, false

// Set this to true to enable Direct Query in addition to Import mode.
//
// *** IMPORTANT ***: Direct Query will only provide a decent user experience
// if you are connecting to a Hive LLAP instance.
//
Config_EnableDirectQuery = true;    // true, false

[DataSource.Kind="HiveSample", Publish="HiveSample.Publish"]
shared HiveSample.Contents = (host as text, port as number) =>
    let
        //
        // Connection string settings
        //
        ConnectionString = [
            Driver = Config_DriverName,

            // set all connection string properties
            host = host,
            port = port,
            authmech = 3,
            thrifttransport=1
        ],

        //
        // Handle credentials
        // Credentials are not persisted with the query and are set through a separate 
        // record field - CredentialConnectionString. The base Odbc.DataSource function
        // will handle UsernamePassword authentication automatically, but it is explictly
        // handled here as an example. 
        //
        Credential = Extension.CurrentCredential(),
		CredentialConnectionString =
            if Credential[AuthenticationKind]? = "UsernamePassword" then
                // set connection string parameters used for basic authentication
                [ UID = Credential[Username], PWD = Credential[Password] ]
            else
                error Error.Record("Error", "Unhandled authentication kind: " & Credential[AuthenticationKind]?),
        
        //
        // Configuration options for the call to Odbc.DataSource
        //
        defaultConfig = BuildOdbcConfig(),

        SqlCapabilities = defaultConfig[SqlCapabilities] & [
            // place custom overrides here
            GroupByCapabilities = SQL_GB[SQL_GB_COLLATE]
        ],

        // Please refer to the ODBC specification for SQLGetInfo properties and values.
        // https://github.com/Microsoft/ODBC-Specification/blob/master/Windows/inc/sqlext.h
        SQLGetInfo = defaultConfig[SQLGetInfo] & [
            // place custom overrides here
            SQL_STRING_FUNCTIONS =
                let
                    // this is the value reported by the driver: 277753
                    driverDefault = {
                        SQL_FN_STR[SQL_FN_STR_CONCAT],
                        SQL_FN_STR[SQL_FN_STR_LTRIM],
                        SQL_FN_STR[SQL_FN_STR_LENGTH],
                        SQL_FN_STR[SQL_FN_STR_LOCATE],
                        SQL_FN_STR[SQL_FN_STR_LCASE],
                        SQL_FN_STR[SQL_FN_STR_REPEAT],
                        SQL_FN_STR[SQL_FN_STR_RTRIM],
                        SQL_FN_STR[SQL_FN_STR_SUBSTRING],
                        SQL_FN_STR[SQL_FN_STR_UCASE],
                        SQL_FN_STR[SQL_FN_STR_ASCII],
                        SQL_FN_STR[SQL_FN_STR_SPACE]
                    },
                    // add missing string functions
                    updated = driverDefault & {
                        SQL_FN_STR[SQL_FN_STR_LEFT],
                        SQL_FN_STR[SQL_FN_STR_RIGHT] 
                    }
                in
                    Flags(updated),

            SQL_NUMERIC_FUNCTIONS =
                let
                    // this is the value reported by the driver: 8386415
                    driverDefault = {
                        SQL_FN_NUM[SQL_FN_NUM_ABS],
                        SQL_FN_NUM[SQL_FN_NUM_ASIN],
                        SQL_FN_NUM[SQL_FN_NUM_ATAN2],
                        SQL_FN_NUM[SQL_FN_NUM_LOG],
                        SQL_FN_NUM[SQL_FN_NUM_SIN],
                        SQL_FN_NUM[SQL_FN_NUM_SQRT],
                        SQL_FN_NUM[SQL_FN_NUM_LOG10],
                        SQL_FN_NUM[SQL_FN_NUM_POWER],
                        SQL_FN_NUM[SQL_FN_NUM_RADIANS]
                    },
                    // add missing functions
                    updated = driverDefault & {
                        SQL_FN_NUM[SQL_FN_NUM_MOD]
                    }
                in
                    Flags(updated)
        ],

        // SQLGetTypeInfo can be specified in two ways:
        // 1. A #table() value that returns the same type information as an ODBC
        //    call to SQLGetTypeInfo.
        // 2. A function that accepts a table argument, and returns a table. The 
        //    argument will contain the original results of the ODBC call to SQLGetTypeInfo.
        //    Your function implementation can modify/add to this table.
        //
        // For details of the format of the types table parameter and expected return value,
        // please see: https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlgettypeinfo-function
        //
        // The sample implementation provided here will simply output the original table
        // to the user trace log, without any modification. 
        SQLGetTypeInfo = (types) => 
            if (EnableTraceOutput <> true) then types else
            let
                // Outputting the entire table might be too large, and result in the value being truncated.
                // We can output a row at a time instead with Table.TransformRows()
                rows = Table.TransformRows(types, each Diagnostics.LogValue("SQLGetTypeInfo " & _[TYPE_NAME], _)),
                toTable = Table.FromRecords(rows)
            in
                Value.ReplaceType(toTable, Value.Type(types)),                

        // SQLColumns is a function handler that receives the results of an ODBC call
        // to SQLColumns(). The source parameter contains a table with the data type 
        // information. This override is typically used to fix up data type mismatches
        // between calls to SQLGetTypeInfo and SQLColumns. 
        //
        // For details of the format of the source table parameter, please see:
        // https://docs.microsoft.com/en-us/sql/odbc/reference/syntax/sqlcolumns-function
        //
        // The sample implementation provided here will simply output the original table
        // to the user trace log, without any modification. 
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

        // This record allows you to customize the generated SQL for certain
        // operations. The most common usage is to define syntax for LIMIT/OFFSET operators 
        // when TOP is not supported. 
        // 
        AstVisitor = [
            // format is "LIMIT [<skip>,]<take>" - ex. LIMIT 2,10 or LIMIT 10
            LimitClause = (skip, take) =>
                if (take = null) then
                    ...
                else
                    let
                        skip =
                            if (skip = null or skip = 0) then
                                ""
                            else
                                Number.ToText(skip) & ","
                    in
                        [
                            Text = Text.Format("LIMIT #{0}#{1}", { skip, take }),
                            Location = "AfterQuerySpecification"
                        ]
        ],

        OdbcDatasource = Odbc.DataSource(ConnectionString, [
            // A logical (true/false) that sets whether to view the tables grouped by their schema names
            HierarchicalNavigation = true, 
            // Prevents execution of native SQL statements. Extensions should set this to true.
            HideNativeQuery = true,
            // Enables connection pooling via the system ODBC manager
            ClientConnectionPooling = true,
            // Show table relationships
            CreateNavigationProperties = true,

            // These values should be set by previous steps
            CredentialConnectionString = CredentialConnectionString,
            AstVisitor = AstVisitor,
            SqlCapabilities = SqlCapabilities,
            SQLColumns = SQLColumns,
            SQLGetInfo = SQLGetInfo,
            SQLGetTypeInfo = SQLGetTypeInfo
        ])
    in
        OdbcDatasource;  

// Data Source Kind description
HiveSample = [
    // Set the TestConnection handler to enable gateway support.
    // The TestConnection handler will invoke your data source function to 
    // validate the credentials the user has provider. Ideally, this is not 
    // an expensive operation to perform. By default, the dataSourcePath value 
    // will be a json string containing the required parameters of your data  
    // source function. These should be parsed and parsed as individual parameters
    // to the specified data source function.
    TestConnection = (dataSourcePath) => 
        let
            json = Json.Document(dataSourcePath),
            host = json[host],   // name of function parameter
            port = json[port]   // name of function parameter
        in
            { "HiveSample.Contents", host, port },
    // Set supported types of authentication
    Authentication = [
        UsernamePassword = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
HiveSample.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",

    SupportsDirectQuery = Config_EnableDirectQuery,

    SourceImage = HiveSample.Icons,
    SourceTypeImage = HiveSample.Icons
];

HiveSample.Icons = [
    Icon16 = { Extension.Contents("HiveSample16.png"), Extension.Contents("HiveSample20.png"), Extension.Contents("HiveSample24.png"), Extension.Contents("HiveSample32.png") },
    Icon32 = { Extension.Contents("HiveSample32.png"), Extension.Contents("HiveSample40.png"), Extension.Contents("HiveSample48.png"), Extension.Contents("HiveSample64.png") }
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

// Expose the constants and bitfield helpers
Flags = ODBC[Flags];
SQL_FN_STR = ODBC[SQL_FN_STR];
SQL_SC = ODBC[SQL_SC];
SQL_GB = ODBC[SQL_GB];
SQL_FN_NUM = ODBC[SQL_FN_NUM];

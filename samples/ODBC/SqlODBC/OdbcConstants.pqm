// values from https://github.com/Microsoft/ODBC-Specification/blob/master/Windows/inc/sqlext.h
[
    Flags = (flags as list) => 
        if (List.IsEmpty(flags)) then 0 else
        let
            Loop = List.Generate(()=> [i = 0, Combined = flags{0}],
                                    each [i] < List.Count(flags),
                                    each [Combined = Number.BitwiseOr([Combined], flags{i}), i = [i]+1],
                                    each [Combined]),
            Result = List.Last(Loop)
        in
            Result,

    SQL_HANDLE =
    [
        ENV = 1,
        DBC = 2,
        STMT = 3,
        DESC = 4
    ],

    RetCode =
    [
        SUCCESS = 0,
        SUCCESS_WITH_INFO = 1,
        ERROR = -1,
        INVALID_HANDLE = -2,
        NO_DATA = 100
    ],

    SQL_CONVERT =
    [
        BIGINT = 53,
        BINARY = 54,
        BIT = 55,
        CHAR = 56,
        DATE = 57,
        DECIMAL = 58,
        DOUBLE = 59,
        FLOAT = 60,
        INTEGER = 61,
        LONGVARCHAR = 62,
        NUMERIC = 63,
        REAL = 64,
        SMALLINT = 65,
        TIME = 66,
        TIMESTAMP = 67,
        TINYINT = 68,
        VARBINARY = 69,
        VARCHAR = 70,
        LONGVARBINARY = 71
    ],

    SQL_ROW =
    [
        PROCEED = 0,
        IGNORE = 1,
        SUCCESS = 0,
        DELETED = 1,
        UPDATED = 2,
        NOROW = 3,
        ADDED = 4,
        ERROR = 5,
        SUCCESS_WITH_INFO = 6
    ],

SQL_CVT =
[
    //None = 0,

    CHAR = 0x00000001,
    NUMERIC = 0x00000002,
    DECIMAL = 0x00000004,
    INTEGER = 0x00000008,
    SMALLINT = 0x00000010,
    FLOAT = 0x00000020,
    REAL = 0x00000040,
    DOUBLE = 0x00000080,
    VARCHAR = 0x00000100,
    LONGVARCHAR = 0x00000200,
    BINARY = 0x00000400,
    VARBINARY = 0x00000800,
    BIT = 0x00001000,
    TINYINT = 0x00002000,
    BIGINT = 0x00004000,
    DATE = 0x00008000,
    TIME = 0x00010000,
    TIMESTAMP = 0x00020000,
    LONGVARBINARY = 0x00040000,
    INTERVAL_YEAR_MONTH = 0x00080000,
    INTERVAL_DAY_TIME = 0x00100000,
    WCHAR = 0x00200000,
    WLONGVARCHAR = 0x00400000,
    WVARCHAR = 0x00800000,
    GUID = 0x01000000
],

    STMT =
    [
        CLOSE = 0,
        DROP = 1,
        UNBIND = 2,
        RESET_PARAMS = 3
    ],

    SQL_MAX =
    [
        NUMERIC_LEN = 16
    ],

    SQL_IS =
    [
        POINTER = -4,
        INTEGER = -6,
        UINTEGER = -5,
        SMALLINT = -8
    ],

    //SQL Server specific defines
    //
    SQL_HC =                        // from Odbcss.h
    [
        OFF = 0,                //  FOR BROWSE columns are hidden
        ON = 1                //  FOR BROWSE columns are exposed
    ],

    SQL_NB =                         // from Odbcss.h
    [
        OFF = 0,                //  NO_BROWSETABLE is off
        ON = 1                //  NO_BROWSETABLE is on
    ],

    //  SQLColAttributes driver specific defines.
    //  SQLSet/GetDescField driver specific defines.
    //  Microsoft has 1200 thru 1249 reserved for Microsoft SQL Server driver usage.
    //
    SQL_CA_SS =                      // from Odbcss.h
    [
        BASE = 1200,           // SQL_CA_SS_BASE

        COLUMN_HIDDEN = 1200 + 11,      //  Column is hidden (FOR BROWSE)
        COLUMN_KEY = 1200 + 12,      //  Column is key column (FOR BROWSE)
        VARIANT_TYPE = 1200 + 15,
        VARIANT_SQL_TYPE = 1200 + 16,
        VARIANT_SERVER_TYPE = 1200 + 17

    ],

    SQL_SOPT_SS =                    // from Odbcss.h
    [
        BASE = 1225,                // SQL_SOPT_SS_BASE
        HIDDEN_COLUMNS = 1225 + 2,  // Expose FOR BROWSE hidden columns
        NOBROWSETABLE = 1225 + 3    // Set NOBROWSETABLE option
    ],

    SQL_COMMIT = 0,      //Commit
    SQL_ROLLBACK = 1,      //Abort

    //static public readonly IntPtr SQL_AUTOCOMMIT_OFF = IntPtr.Zero;
    //static public readonly IntPtr SQL_AUTOCOMMIT_ON = new IntPtr(1);

    SQL_TRANSACTION =
    [
        READ_UNCOMMITTED = 0x00000001,
        READ_COMMITTED = 0x00000002,
        REPEATABLE_READ = 0x00000004,
        SERIALIZABLE = 0x00000008,
        SNAPSHOT = 0x00000020 // VSDD 414121: SQL_TXN_SS_SNAPSHOT == 0x20 (sqlncli.h)
    ],

    SQL_PARAM =
    [
        TYPE_UNKNOWN = 0,          // SQL_PARAM_TYPE_UNKNOWN
        INPUT = 1,                 // SQL_PARAM_INPUT
        INPUT_OUTPUT = 2,          // SQL_PARAM_INPUT_OUTPUT
        RESULT_COL =   3,          // SQL_RESULT_COL
        OUTPUT = 4,                // SQL_PARAM_OUTPUT
        RETURN_VALUE = 5           // SQL_RETURN_VALUE
    ],

    SQL_DESC =
    [
        // from sql.h (ODBCVER >= 3.0)
        //
        COUNT = 1001,
        TYPE = 1002,
        LENGTH = 1003,
        OCTET_LENGTH_PTR = 1004,
        PRECISION = 1005,
        SCALE = 1006,
        DATETIME_INTERVAL_CODE = 1007,
        NULLABLE = 1008,
        INDICATOR_PTR = 1009,
        DATA_PTR = 1010,
        NAME = 1011,
        UNNAMED = 1012,
        OCTET_LENGTH = 1013,
        ALLOC_TYPE = 1099,

        // from sqlext.h (ODBCVER >= 3.0)
        //
        CONCISE_TYPE = SQL_COLUMN[TYPE],
        DISPLAY_SIZE = SQL_COLUMN[DISPLAY_SIZE],
        UNSIGNED = SQL_COLUMN[UNSIGNED],
        UPDATABLE = SQL_COLUMN[UPDATABLE],
        AUTO_UNIQUE_VALUE = SQL_COLUMN[AUTO_INCREMENT],

        TYPE_NAME = SQL_COLUMN[TYPE_NAME],
        TABLE_NAME = SQL_COLUMN[TABLE_NAME],
        SCHEMA_NAME = SQL_COLUMN[OWNER_NAME],
        CATALOG_NAME = SQL_COLUMN[QUALIFIER_NAME],

        BASE_COLUMN_NAME = 22,
        BASE_TABLE_NAME = 23,

        NUM_PREC_RADIX = 32
    ],

    // ODBC version 2.0 style attributes
    // All IdentifierValues are ODBC 1.0 unless marked differently
    //
    SQL_COLUMN =
    [
        COUNT = 0,
        NAME = 1,
        TYPE = 2,
        LENGTH = 3,
        PRECISION = 4,
        SCALE = 5,
        DISPLAY_SIZE = 6,
        NULLABLE = 7,
        UNSIGNED = 8,
        MONEY = 9,
        UPDATABLE = 10,
        AUTO_INCREMENT = 11,
        CASE_SENSITIVE = 12,
        SEARCHABLE = 13,
        TYPE_NAME = 14,
        TABLE_NAME = 15,    // (ODBC 2.0)
        OWNER_NAME = 16,    // (ODBC 2.0)
        QUALIFIER_NAME = 17,    // (ODBC 2.0)
        LABEL = 18
    ],

    // values from sqlext.h
    SQL_SQL92_RELATIONAL_JOIN_OPERATORS =
    [
        CORRESPONDING_CLAUSE = 0x00000001,    // SQL_SRJO_CORRESPONDING_CLAUSE
        CROSS_JOIN = 0x00000002,    // SQL_SRJO_CROSS_JOIN
        EXCEPT_JOIN = 0x00000004,    // SQL_SRJO_EXCEPT_JOIN
        FULL_OUTER_JOIN = 0x00000008,    // SQL_SRJO_FULL_OUTER_JOIN
        INNER_JOIN = 0x00000010,    // SQL_SRJO_INNER_JOIN
        INTERSECT_JOIN = 0x00000020,    // SQL_SRJO_INTERSECT_JOIN
        LEFT_OUTER_JOIN = 0x00000040,    // SQL_SRJO_LEFT_OUTER_JOIN
        NATURAL_JOIN = 0x00000080,    // SQL_SRJO_NATURAL_JOIN
        RIGHT_OUTER_JOIN = 0x00000100,  // SQL_SRJO_RIGHT_OUTER_JOIN
        UNION_JOIN = 0x00000200         // SQL_SRJO_UNION_JOIN
    ],

    // values from sqlext.h
    SQL_QU = 
    [
        SQL_QU_DML_STATEMENTS = 0x00000001,
        SQL_QU_PROCEDURE_INVOCATION = 0x00000002,
        SQL_QU_TABLE_DEFINITION     = 0x00000004,
        SQL_QU_INDEX_DEFINITION     = 0x00000008,
        SQL_QU_PRIVILEGE_DEFINITION = 0x00000010
    ],

    // values from sql.h
    SQL_OJ_CAPABILITIES =
    [
        LEFT = 0x00000001,    // SQL_OJ_LEFT
        RIGHT = 0x00000002,    // SQL_OJ_RIGHT
        FULL = 0x00000004,    // SQL_OJ_FULL
        NESTED = 0x00000008,    // SQL_OJ_NESTED
        NOT_ORDERED = 0x00000010,    // SQL_OJ_NOT_ORDERED
        INNER = 0x00000020,    // SQL_OJ_INNER
        ALL_COMPARISON_OPS = 0x00000040  //SQL_OJ_ALLCOMPARISION+OPS
    ],

    SQL_UPDATABLE =
    [
        READONLY = 0,          // SQL_ATTR_READ_ONLY
        WRITE = 1,             // SQL_ATTR_WRITE
        READWRITE_UNKNOWN = 2  // SQL_ATTR_READWRITE_UNKNOWN
    ],

    SQL_IDENTIFIER_CASE =
    [
        UPPER = 1,    // SQL_IC_UPPER
        LOWER = 2,    // SQL_IC_LOWER
        SENSITIVE = 3,    // SQL_IC_SENSITIVE
        MIXED = 4    // SQL_IC_MIXED
    ],

    // Uniqueness parameter in the SQLStatistics function
    SQL_INDEX =
    [
        UNIQUE = 0,
        ALL = 1
    ],

    // Reserved parameter in the SQLStatistics function
    SQL_STATISTICS_RESERVED =
    [
        QUICK = 0,                // SQL_QUICK
        ENSURE = 1                // SQL_ENSURE
    ],

    // Identifier type parameter in the SQLSpecialColumns function
    SQL_SPECIALCOLS =
    [
        BEST_ROWID = 1,            // SQL_BEST_ROWID
        ROWVER = 2            // SQL_ROWVER
    ],

    // Scope parameter in the SQLSpecialColumns function
    SQL_SCOPE =
    [
        CURROW = 0,            // SQL_SCOPE_CURROW
        TRANSACTION = 1,           // SQL_SCOPE_TRANSACTION
        SESSION = 2           // SQL_SCOPE_SESSION
    ],

    SQL_NULLABILITY =
    [
        NO_NULLS = 0,                // SQL_NO_NULLS
        NULLABLE = 1,                // SQL_NULLABLE
        UNKNOWN = 2                 // SQL_NULLABLE_UNKNOWN
    ],

    SQL_SEARCHABLE =
    [
        UNSEARCHABLE = 0,        // SQL_UNSEARCHABLE
        LIKE_ONLY = 1,        // SQL_LIKE_ONLY
        ALL_EXCEPT_LIKE = 2,        // SQL_ALL_EXCEPT_LIKE
        SEARCHABLE = 3        // SQL_SEARCHABLE
    ],

    SQL_UNNAMED =
    [
        NAMED = 0,                   // SQL_NAMED
        UNNAMED = 1                  // SQL_UNNAMED
    ],
    // todo:move
    // internal constants
    // not odbc specific
    //
    HANDLER =
    [
        IGNORE = 0x00000000,
        THROW = 0x00000001
    ],

    // values for SQLStatistics TYPE column
    SQL_STATISTICSTYPE =
    [
        TABLE_STAT = 0,                    // TABLE Statistics
        INDEX_CLUSTERED = 1,               // CLUSTERED index statistics
        INDEX_HASHED = 2,                  // HASHED index statistics
        INDEX_OTHER = 3                    // OTHER index statistics
    ],

    // values for SQLProcedures PROCEDURE_TYPE column
    SQL_PROCEDURETYPE =
    [
        UNKNOWN = 0,                    // procedure is of unknow type
        PROCEDURE = 1,                    // procedure is a procedure
        FUNCTION = 2                     // procedure is a function
    ],

    // private constants
    // to define data types (see below)
    //
    SIGNED_OFFSET = -20,      // SQL_SIGNED_OFFSET
    UNSIGNED_OFFSET = -22,    // SQL_UNSIGNED_OFFSET

    // C Data Types
    SQL_C =
    [
        CHAR            = 1,
        WCHAR           = -8,
        SLONG           = 4     + SIGNED_OFFSET,
        ULONG           = 4     + UNSIGNED_OFFSET,
        SSHORT          = 5     + SIGNED_OFFSET,
        USHORT          = 5     + UNSIGNED_OFFSET,
        FLOAT           = 7,
        DOUBLE          = 8,
        BIT             = -7,
        STINYINT        = -6    + SIGNED_OFFSET,
        UTINYINT        = -6    + UNSIGNED_OFFSET,
        SBIGINT         = -5    + SIGNED_OFFSET,
        UBIGINT         = -5    + UNSIGNED_OFFSET,
        BINARY          = -2,
        TIMESTAMP       = 11,

        TYPE_DATE       = 91,
        TYPE_TIME       = 92,
        TYPE_TIMESTAMP  = 93,

        NUMERIC         = 2,
        GUID            = -11,
        DEFAULT         = 99,
        ARD_TYPE        = -99
    ],

    // SQL Data Types
    SQL_TYPE =
    [
        // Base data types (sql.h)
        UNKNOWN             = 0,
        NULL                = 0,
        CHAR                = 1,
        NUMERIC             = 2,
        DECIMAL             = 3,
        INTEGER             = 4,
        SMALLINT            = 5,
        FLOAT               = 6,
        REAL                = 7,
        DOUBLE              = 8,
        DATETIME            = 9,      // V3 Only
        VARCHAR             = 12,

        // Unicode types (sqlucode.h)
        WCHAR               = -8,
        WVARCHAR            = -9,
        WLONGVARCHAR        = -10,

        // Extended data types (sqlext.h)
        INTERVAL            = 10,    // V3 Only
        TIME                = 10,
        TIMESTAMP           = 11,
        LONGVARCHAR         = -1,
        BINARY              = -2,
        VARBINARY           = -3,
        LONGVARBINARY       = -4,
        BIGINT              = -5,
        TINYINT             = -6,
        BIT                 = -7,
        GUID                = -11,   // V3 Only

        // One-parameter shortcuts for date/time data types.
        TYPE_DATE           = 91,
        TYPE_TIME           = 92,
        TYPE_TIMESTAMP      = 93,

        // SQL Server Types -150 to -159 (sqlncli.h)
        SS_VARIANT          = -150,
        SS_UDT              = -151,
        SS_XML              = -152,
        SS_TABLE            = -153,
        SS_TIME2            = -154,
        SS_TIMESTAMPOFFSET  = -155
    ],

    //SQL_ALL_TYPES = 0,
    //static public readonly IntPtr SQL_HANDLE_NULL = IntPtr.Zero;

    SQL_LENGTH = 
    [
        SQL_IGNORE = -6,
        SQL_DEFAULT_PARAM = -5,
        SQL_NO_TOTAL = -4,
        SQL_NTS = -3,
        SQL_DATA_AT_EXEC = -2,
        SQL_NULL_DATA = -1
    ],

    SQL_DEFAULT_PARAM = -5,        

    // column ordinals for SQLProcedureColumns result set
    // this column ordinals are not defined in any c/c++ header but in the ODBC Programmer's Reference under SQLProcedureColumns
    //
    COLUMN_NAME = 4,
    COLUMN_TYPE = 5,
    DATA_TYPE = 6,
    COLUMN_SIZE = 8,
    DECIMAL_DIGITS = 10,
    NUM_PREC_RADIX = 11,

    SQL_ATTR = 
    [
        ODBC_VERSION = 200,
        CONNECTION_POOLING = 201,
        AUTOCOMMIT = 102,
        TXN_ISOLATION = 108,
        CURRENT_CATALOG = 109,
        LOGIN_TIMEOUT = 103,
        QUERY_TIMEOUT = 0,
        CONNECTION_DEAD = 1209,

        SQL_COPT_SS_BASE = 1200,
        SQL_COPT_SS_ENLIST_IN_DTC = (1200 + 7),
        SQL_COPT_SS_TXN_ISOLATION = (1200 + 27),

        MAX_LENGTH = 3,
        ROW_BIND_TYPE = 5,
        CURSOR_TYPE = 6,
        RETRIEVE_DATA = 11,
        ROW_STATUS_PTR = 25, 
        ROWS_FETCHED_PTR = 26,
        ROW_ARRAY_SIZE = 27,

        // ODBC 3.0
        APP_ROW_DESC = 10010,
        APP_PARAM_DESC = 10011,
        IMP_ROW_DESC = 10012,
        IMP_PARAM_DESC = 10013,
        METADATA_ID = 10014,

        // ODBC 4.0
        PRIVATE_DRIVER_LOCATION = 204
    ],

    SQL_RD = 
    [
        OFF = 0,
        ON = 1
    ],

    SQL_GD = 
    [
        //None =  0,
        ANY_COLUMN = 1,
        ANY_ORDER = 2,
        BLOCK = 4,
        BOUND = 8,
        OUTPUT_PARAMS = 16
    ],

    //SQLGetInfo
/*
    SQL_INFO =
    [
        SQL_ACTIVE_CONNECTIONS = 0,        
        SQL_MAX_DRIVER_CONNECTIONS = 0,
        SQL_MAX_CONCURRENT_ACTIVITIES = 1,
        SQL_ACTIVE_STATEMENTS = 1,         
        SQL_DATA_SOURCE_NAME = 2,          
        SQL_DRIVER_HDBC,                   
        SQL_DRIVER_HENV,                   
        SQL_DRIVER_HSTMT,                  
        SQL_DRIVER_NAME,                   
        SQL_DRIVER_VER,                    
        SQL_FETCH_DIRECTION,               
        SQL_ODBC_API_CONFORMANCE,          
        SQL_ODBC_VER,                      
        SQL_ROW_UPDATES,                   
        SQL_ODBC_SAG_CLI_CONFORMANCE,      
        SQL_SERVER_NAME,                   
        SQL_SEARCH_PATTERN_ESCAPE,         
        SQL_ODBC_SQL_CONFORMANCE,          

        SQL_DATABASE_NAME,                 
        SQL_DBMS_NAME,                     
        SQL_DBMS_VER,                      

        SQL_ACCESSIBLE_TABLES,             
        SQL_ACCESSIBLE_PROCEDURES,         
        SQL_PROCEDURES,                    
        SQL_CONCAT_NULL_BEHAVIOR,          
        SQL_CURSOR_COMMIT_BEHAVIOR,        
        SQL_CURSOR_ROLLBACK_BEHAVIOR,      
        SQL_DATA_SOURCE_READ_ONLY,         
        SQL_DEFAULT_TXN_ISOLATION,         
        SQL_EXPRESSIONS_IN_ORDERBY,        
        SQL_IDENTIFIER_CASE,               
        SQL_IDENTIFIER_QUOTE_CHAR,         
        SQL_MAX_COLUMN_NAME_LEN,           
        SQL_MAX_CURSOR_NAME_LEN,           
        SQL_MAX_OWNER_NAME_LEN,            
        SQL_MAX_SCHEMA_NAME_LEN = 32,
        SQL_MAX_PROCEDURE_NAME_LEN,        
        SQL_MAX_QUALIFIER_NAME_LEN,        
        SQL_MAX_CATALOG_NAME_LEN = 34,
        SQL_MAX_TABLE_NAME_LEN,            
        SQL_MULT_RESULT_SETS,              
        SQL_MULTIPLE_ACTIVE_TXN,           
        SQL_OUTER_JOINS,                   
        SQL_SCHEMA_TERM,                   
        SQL_PROCEDURE_TERM,                
        SQL_CATALOG_NAME_SEPARATOR,        
        SQL_CATALOG_TERM,                  
        SQL_SCROLL_CONCURRENCY,            
        SQL_SCROLL_OPTIONS,                
        SQL_TABLE_TERM,                    
        SQL_TXN_CAPABLE,                   
        SQL_USER_NAME,                     

        SQL_CONVERT_FUNCTIONS,             
        SQL_NUMERIC_FUNCTIONS,             
        SQL_STRING_FUNCTIONS,              
        SQL_SYSTEM_FUNCTIONS,              
        SQL_TIMEDATE_FUNCTIONS,            

        SQL_CONVERT_BIGINT,
        SQL_CONVERT_BINARY,
        SQL_CONVERT_BIT,
        SQL_CONVERT_CHAR,
        SQL_CONVERT_DATE,
        SQL_CONVERT_DECIMAL,
        SQL_CONVERT_DOUBLE,
        SQL_CONVERT_FLOAT,            
        SQL_CONVERT_INTEGER,
        SQL_CONVERT_LONGVARCHAR,
        SQL_CONVERT_NUMERIC,
        SQL_CONVERT_REAL,
        SQL_CONVERT_SMALLINT,
        SQL_CONVERT_TIME,
        SQL_CONVERT_TIMESTAMP,
        SQL_CONVERT_TINYINT,
        SQL_CONVERT_VARBINARY,
        SQL_CONVERT_VARCHAR,          
        SQL_CONVERT_LONGVARBINARY,

        SQL_TXN_ISOLATION_OPTION,     
        SQL_ODBC_SQL_OPT_IEF,
        SQL_INTEGRITY = 73,
        SQL_CORRELATION_NAME,
        SQL_NON_NULLABLE_COLUMNS,
        SQL_DRIVER_HLIB,
        SQL_DRIVER_ODBC_VER,
        SQL_LOCK_TYPES,
        SQL_POS_OPERATIONS,
        SQL_POSITIONED_STATEMENTS,        
        SQL_GETDATA_EXTENSIONS,
        SQL_BOOKMARK_PERSISTENCE,
        SQL_STATIC_SENSITIVITY,
        SQL_FILE_USAGE,
        SQL_NULL_COLLATION,
        SQL_ALTER_TABLE,
        SQL_COLUMN_ALIAS,
        SQL_GROUP_BY,
        SQL_KEYWORDS,
        SQL_ORDER_BY_COLUMNS_IN_SELECT,   
        SQL_SCHEMA_USAGE,
        SQL_CATALOG_USAGE,
        SQL_QUOTED_IDENTIFIER_CASE,
        SQL_SPECIAL_CHARACTERS,
        SQL_SUBQUERIES,
        SQL_UNION_STATEMENT,
        SQL_MAX_COLUMNS_IN_GROUP_BY,
        SQL_MAX_COLUMNS_IN_INDEX,
        SQL_MAX_COLUMNS_IN_ORDER_BY,
        SQL_MAX_COLUMNS_IN_SELECT,        
        SQL_MAX_COLUMNS_IN_TABLE,
        SQL_MAX_INDEX_SIZE,
        SQL_MAX_ROW_SIZE_INCLUDES_LONG,
        SQL_MAX_ROW_SIZE,
        SQL_MAX_STATEMENT_LEN,
        SQL_MAX_TABLES_IN_SELECT,
        SQL_MAX_USER_NAME_LEN,
        SQL_MAX_CHAR_LITERAL_LEN,
        SQL_TIMEDATE_ADD_INTERVALS,
        SQL_TIMEDATE_DIFF_INTERVALS,      
        SQL_NEED_LONG_DATA_LEN,
        SQL_MAX_BINARY_LITERAL_LEN,
        SQL_LIKE_ESCAPE_CLAUSE,
        SQL_CATALOG_LOCATION,
        SQL_OJ_CAPABILITIES,

        SQL_ACTIVE_ENVIRONMENTS,
        SQL_ALTER_DOMAIN,
        SQL_SQL_CONFORMANCE,
        SQL_DATETIME_LITERALS,
        SQL_BATCH_ROW_COUNT,              
        SQL_BATCH_SUPPORT,
        SQL_CONVERT_WCHAR,
        SQL_CONVERT_INTERVAL_DAY_TIME,
        SQL_CONVERT_INTERVAL_YEAR_MONTH,
        SQL_CONVERT_WLONGVARCHAR,
        SQL_CONVERT_WVARCHAR,
        SQL_CREATE_ASSERTION,
        SQL_CREATE_CHARACTER_SET,
        SQL_CREATE_COLLATION,
        SQL_CREATE_DOMAIN,                  
        SQL_CREATE_SCHEMA,
        SQL_CREATE_TABLE,
        SQL_CREATE_TRANSLATION,
        SQL_CREATE_VIEW,
        SQL_DRIVER_HDESC,
        SQL_DROP_ASSERTION,
        SQL_DROP_CHARACTER_SET,
        SQL_DROP_COLLATION,
        SQL_DROP_DOMAIN,
        SQL_DROP_SCHEMA,                    
        SQL_DROP_TABLE,
        SQL_DROP_TRANSLATION,
        SQL_DROP_VIEW,
        SQL_DYNAMIC_CURSOR_ATTRIBUTES1,
        SQL_DYNAMIC_CURSOR_ATTRIBUTES2,
        SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1,
        SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2,
        SQL_INDEX_KEYWORDS,
        SQL_INFO_SCHEMA_VIEWS,
        SQL_KEYSET_CURSOR_ATTRIBUTES1,    
        SQL_KEYSET_CURSOR_ATTRIBUTES2,
        SQL_ODBC_INTERFACE_CONFORMANCE,
        SQL_PARAM_ARRAY_ROW_COUNTS,
        SQL_PARAM_ARRAY_SELECTS,
        SQL_SQL92_DATETIME_FUNCTIONS,
        SQL_SQL92_FOREIGN_KEY_DELETE_RULE,
        SQL_SQL92_FOREIGN_KEY_UPDATE_RULE,
        SQL_SQL92_GRANT,
        SQL_SQL92_NUMERIC_VALUE_FUNCTIONS,
        SQL_SQL92_PREDICATES,              
        SQL_SQL92_RELATIONAL_JOIN_OPERATORS,
        SQL_SQL92_REVOKE,
        SQL_SQL92_ROW_VALUE_CONSTRUCTOR,
        SQL_SQL92_STRING_FUNCTIONS,
        SQL_SQL92_VALUE_EXPRESSIONS,
        SQL_STANDARD_CLI_CONFORMANCE,
        SQL_STATIC_CURSOR_ATTRIBUTES1,
        SQL_STATIC_CURSOR_ATTRIBUTES2,
        SQL_AGGREGATE_FUNCTIONS,
        SQL_DDL_INDEX,                   
        SQL_DM_VER,
        SQL_INSERT_STATEMENT,
        SQL_CONVERT_GUID,

        SQL_XOPEN_CLI_YEAR = 10000,      
        SQL_CURSOR_SENSITIVITY,
        SQL_DESCRIBE_PARAMETER,
        SQL_CATALOG_NAME,
        SQL_COLLATION_SEQ,
        SQL_MAX_IDENTIFIER_LEN,
        SQL_ASYNC_MODE = 10021,          
        SQL_MAX_ASYNC_CONCURRENT_STATEMENTS,

        SQL_DTC_TRANSITION_COST = 1750,
    ],
*/
    SQL_OAC = 
    [
        SQL_OAC_None = 0x0000,
        SQL_OAC_LEVEL1 = 0x0001,
        SQL_OAC_LEVEL2 = 0x0002
    ],

    SQL_OSC = 
    [
        SQL_OSC_MINIMUM = 0x0000,
        SQL_OSC_CORE = 0x0001,
        SQL_OSC_EXTENDED = 0x0002
    ],

    SQL_SCC = 
    [
        SQL_SCC_XOPEN_CLI_VERSION1 = 0x00000001,
        SQL_SCC_ISO92_CLI = 0x00000002
    ],

    SQL_SVE = 
    [
        SQL_SVE_CASE = 0x00000001,
        SQL_SVE_CAST = 0x00000002,
        SQL_SVE_COALESCE = 0x00000004,
        SQL_SVE_NULLIF = 0x00000008
    ],

    SQL_SSF = 
    [
        SQL_SSF_CONVERT = 0x00000001,
        SQL_SSF_LOWER = 0x00000002,
        SQL_SSF_UPPER = 0x00000004,
        SQL_SSF_SUBSTRING = 0x00000008,
        SQL_SSF_TRANSLATE = 0x00000010,
        SQL_SSF_TRIM_BOTH = 0x00000020,
        SQL_SSF_TRIM_LEADING = 0x00000040,
        SQL_SSF_TRIM_TRAILING = 0x00000080
    ],

    SQL_SP = 
    [
        //None = 0,

        SQL_SP_EXISTS = 0x00000001,
        SQL_SP_ISNOTNULL = 0x00000002,
        SQL_SP_ISNULL = 0x00000004,
        SQL_SP_MATCH_FULL = 0x00000008,
        SQL_SP_MATCH_PARTIAL = 0x00000010,
        SQL_SP_MATCH_UNIQUE_FULL = 0x00000020,
        SQL_SP_MATCH_UNIQUE_PARTIAL = 0x00000040,
        SQL_SP_OVERLAPS = 0x00000080,
        SQL_SP_UNIQUE = 0x00000100,
        SQL_SP_LIKE = 0x00000200,
        SQL_SP_IN = 0x00000400,
        SQL_SP_BETWEEN = 0x00000800,
        SQL_SP_COMPARISON = 0x00001000,
        SQL_SP_QUANTIFIED_COMPARISON = 0x00002000,

        All = 0x0000FFFF
    ],

    SQL_OIC =
    [
        SQL_OIC_CORE = 1,
        SQL_OIC_LEVEL1 = 2,
        SQL_OIC_LEVEL2 = 3
    ],

    SQL_USAGE = 
    [
        SQL_U_DML_STATEMENTS = 0x00000001,
        SQL_U_PROCEDURE_INVOCATION = 0x00000002,
        SQL_U_TABLE_DEFINITION = 0x00000004,
        SQL_U_INDEX_DEFINITION = 0x00000008,
        SQL_U_PRIVILEGE_DEFINITION = 0x00000010
    ],

    SQL_GB = 
    [
            
        SQL_GB_NOT_SUPPORTED = 0,
        SQL_GB_GROUP_BY_EQUALS_SELECT = 1,
        SQL_GB_GROUP_BY_CONTAINS_SELECT = 2,
        SQL_GB_NO_RELATION = 3,
        SQL_GB_COLLATE = 4
    ],

    SQL_NC =
    [
        SQL_NC_END = 0,
        SQL_NC_HIGH = 1,
        SQL_NC_LOW = 2,
        SQL_NC_START = 3
    ],

    SQL_CN =
    [
        SQL_CN_None = 0,
        SQL_CN_DIFFERENT = 1,
        SQL_CN_ANY = 2
    ],

    SQL_NNC = 
    [
        SQL_NNC_NULL = 0,
        SQL_NNC_NON_NULL = 1
    ],

    SQL_CB = 
    [
        SQL_CB_NULL = 0,
        SQL_CB_NON_NULL = 1
    ],

    SQL_FD_FETCH = 
    [
        SQL_FD_FETCH_NEXT = 0x00000001,
        SQL_FD_FETCH_FIRST = 0x00000002,
        SQL_FD_FETCH_LAST = 0x00000004,
        SQL_FD_FETCH_PRIOR = 0x00000008,
        SQL_FD_FETCH_ABSOLUTE = 0x00000010,
        SQL_FD_FETCH_RELATIVE = 0x00000020,
        SQL_FD_FETCH_BOOKMARK = 0x00000080
    ],

    SQL_SQ = 
    [
        SQL_SQ_COMPARISON = 0x00000001,
        SQL_SQ_EXISTS = 0x00000002,
        SQL_SQ_IN = 0x00000004,
        SQL_SQ_QUANTIFIED = 0x00000008,
        SQL_SQ_CORRELATED_SUBQUERIES = 0x00000010
    ],

    SQL_U = 
    [
        SQL_U_UNION = 0x00000001,
        SQL_U_UNION_ALL = 0x00000002
    ],

    SQL_BP = 
    [
        SQL_BP_CLOSE = 0x00000001,
        SQL_BP_DELETE = 0x00000002,
        SQL_BP_DROP = 0x00000004,
        SQL_BP_TRANSACTION = 0x00000008,
        SQL_BP_UPDATE = 0x00000010,
        SQL_BP_OTHER_HSTMT = 0x00000020,
        SQL_BP_SCROLL = 0x00000040
    ],

    SQL_QL = 
    [
        SQL_QL_START = 0x0001,
        SQL_QL_END = 0x0002
    ],

    SQL_OJ = 
    [
        SQL_OJ_LEFT = 0x00000001,
        SQL_OJ_RIGHT = 0x00000002,
        SQL_OJ_FULL = 0x00000004,
        SQL_OJ_NESTED = 0x00000008,
        SQL_OJ_NOT_ORDERED = 0x00000010,
        SQL_OJ_INNER = 0x00000020,
        SQL_OJ_ALL_COMPARISON_OPS = 0x00000040
    ],

    SQL_FN_CVT = 
    [
        //None = 0,

        SQL_FN_CVT_CONVERT        = 0x00000001,
        SQL_FN_CVT_CAST        = 0x00000002
    ],

    SQL_FN_NUM = 
    [
        //None = 0,

        SQL_FN_NUM_ABS        = 0x00000001,
        SQL_FN_NUM_ACOS        = 0x00000002,
        SQL_FN_NUM_ASIN        = 0x00000004,
        SQL_FN_NUM_ATAN        = 0x00000008,
        SQL_FN_NUM_ATAN2    = 0x00000010,
        SQL_FN_NUM_CEILING    = 0x00000020,
        SQL_FN_NUM_COS        = 0x00000040,
        SQL_FN_NUM_COT        = 0x00000080,
        SQL_FN_NUM_EXP        = 0x00000100,
        SQL_FN_NUM_FLOOR    = 0x00000200,
        SQL_FN_NUM_LOG        = 0x00000400,
        SQL_FN_NUM_MOD        = 0x00000800,
        SQL_FN_NUM_SIGN        = 0x00001000,
        SQL_FN_NUM_SIN        = 0x00002000,
        SQL_FN_NUM_SQRT        = 0x00004000,
        SQL_FN_NUM_TAN      = 0x00008000,
        SQL_FN_NUM_PI       = 0x00010000,
        SQL_FN_NUM_RAND     = 0x00020000,
        SQL_FN_NUM_DEGREES    = 0x00040000,
        SQL_FN_NUM_LOG10    = 0x00080000,
        SQL_FN_NUM_POWER    = 0x00100000,
        SQL_FN_NUM_RADIANS    = 0x00200000,
        SQL_FN_NUM_ROUND    = 0x00400000,
        SQL_FN_NUM_TRUNCATE = 0x00800000
    ],

    SQL_SNVF = 
    [
        SQL_SNVF_BIT_LENGTH = 0x00000001,
        SQL_SNVF_CHAR_LENGTH = 0x00000002,
        SQL_SNVF_CHARACTER_LENGTH = 0x00000004,
        SQL_SNVF_EXTRACT = 0x00000008,
        SQL_SNVF_OCTET_LENGTH = 0x00000010,
        SQL_SNVF_POSITION = 0x00000020
    ],

    SQL_FN_STR =
    [
        //None = 0,

        SQL_FN_STR_CONCAT            = 0x00000001,
        SQL_FN_STR_INSERT            = 0x00000002,
        SQL_FN_STR_LEFT            = 0x00000004,
        SQL_FN_STR_LTRIM            = 0x00000008,
        SQL_FN_STR_LENGTH            = 0x00000010,
        SQL_FN_STR_LOCATE            = 0x00000020,
        SQL_FN_STR_LCASE            = 0x00000040,
        SQL_FN_STR_REPEAT            = 0x00000080,
        SQL_FN_STR_REPLACE            = 0x00000100,
        SQL_FN_STR_RIGHT            = 0x00000200,
        SQL_FN_STR_RTRIM            = 0x00000400,
        SQL_FN_STR_SUBSTRING        = 0x00000800,
        SQL_FN_STR_UCASE            = 0x00001000,
        SQL_FN_STR_ASCII            = 0x00002000,
        SQL_FN_STR_CHAR            = 0x00004000,
        SQL_FN_STR_DIFFERENCE = 0x00008000,
        SQL_FN_STR_LOCATE_2          = 0x00010000,
        SQL_FN_STR_SOUNDEX          = 0x00020000,
        SQL_FN_STR_SPACE          = 0x00040000,
        SQL_FN_STR_BIT_LENGTH      = 0x00080000,
        SQL_FN_STR_CHAR_LENGTH      = 0x00100000,
        SQL_FN_STR_CHARACTER_LENGTH      = 0x00200000,
        SQL_FN_STR_OCTET_LENGTH = 0x00400000,
        SQL_FN_STR_POSITION = 0x00800000
    ],

    SQL_FN_SYSTEM = 
    [
        //None = 0,

        SQL_FN_SYS_USERNAME = 0x00000001,
        SQL_FN_SYS_DBNAME = 0x00000002,
        SQL_FN_SYS_IFNULL = 0x00000004
    ],

    SQL_FN_TD = 
    [
        //None = 0,

        SQL_FN_TD_NOW            = 0x00000001,
        SQL_FN_TD_CURDATE            = 0x00000002,
        SQL_FN_TD_DAYOFMONTH        = 0x00000004,
        SQL_FN_TD_DAYOFWEEK            = 0x00000008,
        SQL_FN_TD_DAYOFYEAR            = 0x00000010,
        SQL_FN_TD_MONTH            = 0x00000020,
        SQL_FN_TD_QUARTER            = 0x00000040,
        SQL_FN_TD_WEEK            = 0x00000080,
        SQL_FN_TD_YEAR            = 0x00000100,
        SQL_FN_TD_CURTIME            = 0x00000200,
        SQL_FN_TD_HOUR            = 0x00000400,
        SQL_FN_TD_MINUTE            = 0x00000800,
        SQL_FN_TD_SECOND            = 0x00001000,
        SQL_FN_TD_TIMESTAMPADD        = 0x00002000,
        SQL_FN_TD_TIMESTAMPDIFF        = 0x00004000,
        SQL_FN_TD_DAYNAME          = 0x00008000,
        SQL_FN_TD_MONTHNAME          = 0x00010000,
        SQL_FN_TD_CURRENT_DATE      = 0x00020000,
        SQL_FN_TD_CURRENT_TIME      = 0x00040000,
        SQL_FN_TD_CURRENT_TIMESTAMP      = 0x00080000,
        SQL_FN_TD_EXTRACT = 0x00100000
    ],

    SQL_SDF = 
    [
        SQL_SDF_CURRENT_DATE = 0x00000001,
        SQL_SDF_CURRENT_TIME = 0x00000002,
        SQL_SDF_CURRENT_TIMESTAMP = 0x00000004
    ],

    SQL_TSI =
    [
        //None = 0,

        SQL_TSI_FRAC_SECOND = 0x00000001,
        SQL_TSI_SECOND = 0x00000002,
        SQL_TSI_MINUTE = 0x00000004,
        SQL_TSI_HOUR = 0x00000008,
        SQL_TSI_DAY = 0x00000010,
        SQL_TSI_WEEK = 0x00000020,
        SQL_TSI_MONTH = 0x00000040,
        SQL_TSI_QUARTER = 0x00000080,
        SQL_TSI_YEAR = 0x00000100
    ],

    SQL_AF = 
    [
        //None = 0,

        SQL_AF_AVG        = 0x00000001,
        SQL_AF_COUNT    = 0x00000002,
        SQL_AF_MAX        = 0x00000004,
        SQL_AF_MIN        = 0x00000008,
        SQL_AF_SUM        = 0x00000010,
        SQL_AF_DISTINCT    = 0x00000020,
        SQL_AF_ALL        = 0x00000040,

        All = 0xFF
    ],

    SQL_SC = 
    [
        //None = 0,

        SQL_SC_SQL92_ENTRY            = 0x00000001,
        SQL_SC_FIPS127_2_TRANSITIONAL    = 0x00000002,
        SQL_SC_SQL92_INTERMEDIATE        = 0x00000004,
        SQL_SC_SQL92_FULL            = 0x00000008
    ],

    SQL_DL_SQL92 = 
    [
        SQL_DL_SQL92_DATE                    = 0x00000001,
        SQL_DL_SQL92_TIME                    = 0x00000002,
        SQL_DL_SQL92_TIMESTAMP                = 0x00000004,
        SQL_DL_SQL92_INTERVAL_YEAR                = 0x00000008,
        SQL_DL_SQL92_INTERVAL_MONTH                = 0x00000010,
        SQL_DL_SQL92_INTERVAL_DAY                = 0x00000020,
        SQL_DL_SQL92_INTERVAL_HOUR                = 0x00000040,
        SQL_DL_SQL92_INTERVAL_MINUTE            = 0x00000080,
        SQL_DL_SQL92_INTERVAL_SECOND            = 0x00000100,
        SQL_DL_SQL92_INTERVAL_YEAR_TO_MONTH            = 0x00000200,
        SQL_DL_SQL92_INTERVAL_DAY_TO_HOUR            = 0x00000400,
        SQL_DL_SQL92_INTERVAL_DAY_TO_MINUTE            = 0x00000800,
        SQL_DL_SQL92_INTERVAL_DAY_TO_SECOND            = 0x00001000,
        SQL_DL_SQL92_INTERVAL_HOUR_TO_MINUTE        = 0x00002000,
        SQL_DL_SQL92_INTERVAL_HOUR_TO_SECOND        = 0x00004000,
        SQL_DL_SQL92_INTERVAL_MINUTE_TO_SECOND     = 0x00008000
    ],

    SQL_IK = 
    [
        SQL_IK_NONE        = 0x00000000,
        SQL_IK_ASC        = 0x00000001,
        SQL_IK_DESC        = 0x00000002,
        SQL_IK_ALL = 0x00000003 //SQL_IK_ASC | SQL_IK_DESC
    ],

    SQL_ISV = 
    [
        SQL_ISV_ASSERTIONS            = 0x00000001,
        SQL_ISV_CHARACTER_SETS        = 0x00000002,
        SQL_ISV_CHECK_CONSTRAINTS        = 0x00000004,
        SQL_ISV_COLLATIONS            = 0x00000008,
        SQL_ISV_COLUMN_DOMAIN_USAGE        = 0x00000010,
        SQL_ISV_COLUMN_PRIVILEGES        = 0x00000020,
        SQL_ISV_COLUMNS            = 0x00000040,
        SQL_ISV_CONSTRAINT_COLUMN_USAGE    = 0x00000080,
        SQL_ISV_CONSTRAINT_TABLE_USAGE    = 0x00000100,
        SQL_ISV_DOMAIN_CONSTRAINTS        = 0x00000200,
        SQL_ISV_DOMAINS            = 0x00000400,
        SQL_ISV_KEY_COLUMN_USAGE        = 0x00000800,
        SQL_ISV_REFERENTIAL_CONSTRAINTS    = 0x00001000,
        SQL_ISV_SCHEMATA            = 0x00002000,
        SQL_ISV_SQL_LANGUAGES        = 0x00004000,
        SQL_ISV_TABLE_CONSTRAINTS      = 0x00008000,
        SQL_ISV_TABLE_PRIVILEGES      = 0x00010000,
        SQL_ISV_TABLES          = 0x00020000,
        SQL_ISV_TRANSLATIONS      = 0x00040000,
        SQL_ISV_USAGE_PRIVILEGES      = 0x00080000,
        SQL_ISV_VIEW_COLUMN_USAGE      = 0x00100000,
        SQL_ISV_VIEW_TABLE_USAGE = 0x00200000,
        SQL_ISV_VIEWS          = 0x00400000
    ],

    SQL_SRJO = 
    [
        //None = 0,

        SQL_SRJO_CORRESPONDING_CLAUSE = 0x00000001,
        SQL_SRJO_CROSS_JOIN = 0x00000002,
        SQL_SRJO_EXCEPT_JOIN = 0x00000004,
        SQL_SRJO_FULL_OUTER_JOIN = 0x00000008,
        SQL_SRJO_INNER_JOIN = 0x00000010,
        SQL_SRJO_INTERSECT_JOIN = 0x00000020,
        SQL_SRJO_LEFT_OUTER_JOIN = 0x00000040,
        SQL_SRJO_NATURAL_JOIN = 0x00000080,
        SQL_SRJO_RIGHT_OUTER_JOIN = 0x00000100,
        SQL_SRJO_UNION_JOIN = 0x00000200
    ],

    SQL_SRVC = 
    [
        SQL_SRVC_VALUE_EXPRESSION = 0x00000001,
        SQL_SRVC_NULL = 0x00000002,
        SQL_SRVC_DEFAULT = 0x00000004,
        SQL_SRVC_ROW_SUBQUERY = 0x00000008
    ],

    //public static readonly int SQL_OV_ODBC3 = 3;
    //public const Int32 SQL_NTS = -3;       //flags for null-terminated string

    //Pooling
    SQL_CP = 
    [
        OFF = 0,
        ONE_PER_DRIVER = 1,
        ONE_PER_HENV = 2
    ],

/*
    public const Int32 SQL_CD_TRUE = 1;
    public const Int32 SQL_CD_FALSE = 0;

    public const Int32 SQL_DTC_DONE = 0;
    public const Int32 SQL_IS_POINTER = -4;
    public const Int32 SQL_IS_PTR = 1;
*/
    SQL_DRIVER =
    [
        NOPROMPT = 0,
        COMPLETE = 1,
        PROMPT = 2,
        COMPLETE_REQUIRED = 3
    ],

    // Column set for SQLPrimaryKeys
    SQL_PRIMARYKEYS =
    [
        /*
                    CATALOGNAME         = 1,                    // TABLE_CAT
                    SCHEMANAME          = 2,                    // TABLE_SCHEM
                    TABLENAME           = 3,                    // TABLE_NAME
        */
        COLUMNNAME = 4                    // COLUMN_NAME
        /*
                    KEY_SEQ             = 5,                    // KEY_SEQ
                    PKNAME              = 6,                    // PK_NAME
        */
    ],

    // Column set for SQLStatistics
    SQL_STATISTICS =
    [
        /*
                    CATALOGNAME         = 1,                    // TABLE_CAT
                    SCHEMANAME          = 2,                    // TABLE_SCHEM
                    TABLENAME           = 3,                    // TABLE_NAME
                    NONUNIQUE           = 4,                    // NON_UNIQUE
                    INDEXQUALIFIER      = 5,                    // INDEX_QUALIFIER
        */
        INDEXNAME = 6,                    // INDEX_NAME
        /*
                    TYPE                = 7,                    // TYPE
        */
        ORDINAL_POSITION = 8,                    // ORDINAL_POSITION
        COLUMN_NAME = 9                    // COLUMN_NAME
        /*
                    ASC_OR_DESC         = 10,                   // ASC_OR_DESC
                    CARDINALITY         = 11,                   // CARDINALITY
                    PAGES               = 12,                   // PAGES
                    FILTER_CONDITION    = 13,                   // FILTER_CONDITION
        */
    ],

    // Column set for SQLSpecialColumns
    SQL_SPECIALCOLUMNSET =
    [
        /*
                    SCOPE               = 1,                    // SCOPE
        */
        COLUMN_NAME = 2                    // COLUMN_NAME
        /*
                    DATA_TYPE           = 3,                    // DATA_TYPE
                    TYPE_NAME           = 4,                    // TYPE_NAME
                    COLUMN_SIZE         = 5,                    // COLUMN_SIZE
                    BUFFER_LENGTH       = 6,                    // BUFFER_LENGTH
                    DECIMAL_DIGITS      = 7,                    // DECIMAL_DIGITS
                    PSEUDO_COLUMN       = 8,                    // PSEUDO_COLUMN
        */
    ],

    SQL_DIAG =
    [
        CURSOR_ROW_COUNT= -1249,
        ROW_NUMBER = -1248,
        COLUMN_NUMBER = -1247,
        RETURNCODE = 1,
        NUMBER = 2,
        ROW_COUNT = 3,
        SQLSTATE = 4,
        NATIVE = 5,
        MESSAGE_TEXT = 6,
        DYNAMIC_FUNCTION = 7,
        CLASS_ORIGIN = 8,
        SUBCLASS_ORIGIN = 9,
        CONNECTION_NAME = 10,
        SERVER_NAME = 11,
        DYNAMIC_FUNCTION_CODE = 12
    ],

    SQL_SU =
    [
        SQL_SU_DML_STATEMENTS       = 0x00000001,
        SQL_SU_PROCEDURE_INVOCATION = 0x00000002,
        SQL_SU_TABLE_DEFINITION     = 0x00000004,
        SQL_SU_INDEX_DEFINITION     = 0x00000008,
        SQL_SU_PRIVILEGE_DEFINITION = 0x00000010
    ]
]

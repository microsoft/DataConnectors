# DuckDb Connector (FlightSQL / ADBC)

A sample Power Query M connector for **DuckDb** using the **FlightSQL** protocol via **ADBC** (Arrow Database Connectivity). Designed as a reference implementation for partners building FlightSQL-based connectors for Power BI.

## Architecture

Uses **`Adbc.Connection`** exclusively — no ODBC, `Adbc.Query`, or `Adbc.Database` needed.

| Feature | Implementation |
|---|---|
| **Connection** | `Adbc.Connection` via FlightSQL gRPC |
| **Navigation** | Database → Schema → Table via `information_schema` |
| **Query Folding** | `SqlView.Generator` with DuckDb-specific `SqlGenerator` |
| **Type Mapping** | Full DuckDb coverage (BOOLEAN through STRUCT/MAP) |
| **Relationships** | PK/FK detection via `information_schema` constraints |
| **Authentication** | Username/Password, Bearer Token, Anonymous |
| **DirectQuery** | Supported |
| **Native Query** | Supported with folding |

## FlightSQL ADBC Driver

The FlightSQL ADBC driver (`libadbc_driver_flightsql.dll`) ships with both **Power Query SDK Tools** and **Power BI Desktop**. No separate driver installation is needed.

`FlightSqlAdbcConfig.pqm` configures the driver by specifying:
- **Driver location**: folder (`FlightSQL`), file name, and entry point (`FlightSqlDriverInit`)
- **Metadata**: catalog/schema support, identifier quoting, supported table types (`BASE TABLE`, `VIEW`)
- **Type mapping**: references `TypeInfo.pqm` for DuckDB-to-M type resolution

The connector uses `Adbc.Connection` with `grpc://` (TLS disabled) or `grpc+tls://` (TLS enabled) URIs to establish the FlightSQL gRPC connection.

## Files

```
DuckDb/
├── DuckDb.pq                    # Main connector entry point
├── DuckDb.query.pq              # Evaluation query for SDK testing
├── FlightSqlAdbcConfig.pqm      # ADBC driver configuration
├── TypeInfo.pqm                 # DuckDb type → M type mapping
├── SqlGenerator.pqm             # DuckDb SQL generator overrides
├── SqlGeneratorCommon.pqm       # Shared Sql92 base infrastructure
├── DuckDb.proj                  # Power Query SDK project file
├── resources.resx               # Localized strings
└── Tests/
    ├── Credentials/             # Credential files for test authentication
    ├── ParameterQueries/        # Parameter query definitions
    ├── Settings/                # PQTest settings (Sanity, Standard, DatasourceSpecific)
    ├── TestSuites/              # Test cases organized by category
    │   ├── Setup/               # Docker setup, data loading, readme
    │   ├── Sanity/              # Basic connectivity and schema tests
    │   ├── Standard/            # Full functional and query folding tests
    │   ├── DatasourceSpecific/  # DuckDB-specific tests
    │   └── PerfTests/           # Performance test queries
    ├── RunDuckDbTestsWithVSCodeGuide.md   # VS Code test guide
    └── RunDuckDbPerfTestsGuide.md         # Performance test guide
```

## Key Design Decisions

### Adbc.Connection Only
Simplest approach for FlightSQL — directly creates a connection, builds navigation via SQL metadata queries, and wires up `SqlView.Generator` for folding.

### SQL Generator
The query folding engine uses a three-layer override architecture:

| Layer | File | Role |
|---|---|---|
| **SQL92 Base** | `SqlGeneratorCommon.pqm` | Shared infrastructure: type validation, AST helpers, 40+ function stubs, base SQL92 capabilities |
| **DuckDB Overrides** | `SqlGenerator.pqm` | DuckDB dialect: 24 type facets, LIMIT/OFFSET syntax, function remapping, typed literal generation |
| **Connector Wiring** | `DuckDb.pq` | Creates `SqlView.Generator` instance, wires to `Adbc.Connection` via `GetData` |

`SqlGenerator.pqm` loads the base via `Extension.LoadExpression()`, defines an override record, and calls `MergeOverrides("Sql92", Override, false)` to produce the final generator.

**Key DuckDB overrides:**
- **LIMIT/OFFSET**: Translates M's `Table.FirstN`/`Table.Skip` to `LIMIT n OFFSET m`
- **Function remapping**: `TIMESTAMPADD`/`TIMESTAMPDIFF` to DuckDB's `date_add`/`date_diff`, `Text.PositionOf` to `INSTR`, `Text.StartsWith` to `starts_with`
- **Typed literals**: `DATE '2023-01-01'`, `TIMESTAMP '...'`, `TIME '...'`, `CAST(value AS TYPE)` for numeric/string types
- **Type facets**: 24 DuckDB types with `NativeTypeName`, precision, radix, and scale metadata
- **Supported conversions**: Type casting rules (e.g., `BOOLEAN` to `VARCHAR`/`DECIMAL`/`BIGINT`)

Partners building new ADBC connectors can use this as a template: copy `SqlGeneratorCommon.pqm` as-is, then create a dialect-specific `SqlGenerator.pqm` with overrides for their database's SQL syntax and type system.

### Primary & Foreign Keys
Queries `information_schema.table_constraints` + `key_column_usage` for PKs, applies them via `Type.ReplaceTableKeys`. Exposes `GetForeignKeys()` for FK discovery. Power BI uses these to auto-create relationships.

## Supported Types

BOOLEAN, TINYINT, SMALLINT, INTEGER, BIGINT, HUGEINT, FLOAT, DOUBLE, DECIMAL, DATE, TIME, TIMESTAMP, TIMESTAMP WITH TIME ZONE, VARCHAR, CHAR, BLOB, BINARY, UUID, JSON, INTERVAL, ARRAY, STRUCT, MAP

## Testing

Tests require a DuckDB FlightSQL server running locally. See [Test Data Setup](Tests/TestSuites/Setup/readme.md) for Docker container setup and data loading instructions.

- [Running Tests with VS Code](Tests/RunDuckDbTestsWithVSCodeGuide.md) — recommended approach using Test Explorer
- [Running Performance Tests](Tests/RunDuckDbPerfTestsGuide.md) — performance testing with PQPerf

## Building

```powershell
dotnet build DuckDb.proj
```

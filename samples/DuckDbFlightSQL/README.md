# DuckDb Connector (FlightSQL / ADBC)

A sample Power Query M connector for [DuckDb](https://duckdb.org/) using the [FlightSQL](https://arrow.apache.org/docs/format/FlightSql.html) protocol via [ADBC](https://arrow.apache.org/adbc/) (Arrow Database Connectivity). Designed as a reference implementation for partners building FlightSQL-based connectors for Power BI.

## Architecture

| Feature            | Implementation                                          |
| ------------------ | ------------------------------------------------------- |
| **Connection**     | `Adbc.Connection` via FlightSQL gRPC                    |
| **Navigation**     | Database → Schema → Table via `information_schema`      |
| **Query Folding**  | `SqlView.Generator` with DuckDb-specific `SqlGenerator` |
| **Type Mapping**   | Full DuckDb coverage (BOOLEAN through STRUCT/MAP)       |
| **Relationships**  | PK/FK detection via `information_schema` constraints    |
| **Authentication** | Username/Password, Bearer Token, Anonymous              |
| **DirectQuery**    | Supported                                               |
| **Native Query**   | Supported with folding                                  |

## FlightSQL ADBC Driver

The open source [FlightSQL ADBC driver](https://github.com/apache/arrow-adbc/tree/main/go/adbc/driver/flightsql) (`libadbc_driver_flightsql.dll`) ships with both **PowerQuerySDKTools** and **Power BI Desktop**. No separate driver installation is needed.

`FlightSqlAdbcConfig.pqm` configures the driver by specifying:

- **Driver location**: folder (`FlightSQL`), file name, and entry point (`FlightSqlDriverInit`)
- **Metadata**: catalog/schema support, identifier quoting, supported table types (`BASE TABLE`, `VIEW`)
- **Type mapping**: references `TypeInfo.pqm` for DuckDB-to-M type resolution

The connector uses `Adbc.Connection` with `grpc://` (TLS disabled) or `grpc+tls://` (TLS enabled) URIs to establish the FlightSQL gRPC connection.

## Files

```text
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
    │   ├── DatasourceSpecific/  # DuckDB-specific tests
    │   └── PerfTests/           # Performance test queries
    │   # Sanity & Standard tests use shared testframework/tests/TestSuites/
    ├── RunDuckDbTestsWithVSCodeGuide.md   # VS Code test guide
    └── RunDuckDbPerfTestsGuide.md         # Performance test guide
```

## Key Design Decisions

### SQL Generator

`SqlView.Generator(id, generator, getData)` is the engine-provided helper that plugs a SQL dialect into M's query-folding pipeline. `id` is a record uniquely identifying the source (this sample uses `[Module, Signature]`); `generator` is the merged SQL92-based generator record produced by `SqlGenerator.pqm`; `getData` is the callback that executes a generated SQL string and returns a table. The returned table folds downstream operations such as `Table.SelectRows`, `Table.Group`, and `Table.Sort` into the dialect's SQL.

The query folding engine uses a two-layer override architecture:

| Layer                | File                     | Role                                                                                              |
| -------------------- | ------------------------ | ------------------------------------------------------------------------------------------------- |
| **SQL92 Base**       | `SqlGeneratorCommon.pqm` | Shared infrastructure: type validation, AST helpers, 40+ function stubs, base SQL92 capabilities  |
| **DuckDB Overrides** | `SqlGenerator.pqm`       | DuckDB dialect: 24 type facets, LIMIT/OFFSET syntax, function remapping, typed literal generation |

`SqlGenerator.pqm` loads the base via `Extension.LoadExpression()`, defines an override record, and calls `MergeOverrides("Sql92", Override, false)` to produce the final generator.

**Key DuckDB overrides:**

- **LIMIT/OFFSET**: Translates M's `Table.FirstN`/`Table.Skip` to `LIMIT n OFFSET m`
- **Function remapping**: `TIMESTAMPADD`/`TIMESTAMPDIFF` to DuckDB's `date_add`/`date_diff`, `Text.PositionOf` to `INSTR`, `Text.StartsWith` to `starts_with`
- **Typed literals**: `DATE '2023-01-01'`, `TIMESTAMP '...'`, `TIME '...'`, `CAST(value AS TYPE)` for numeric/string types
- **Type facets**: 24 DuckDB types with `NativeTypeName`, precision, radix, and scale metadata
- **Supported conversions**: Type casting rules (e.g., `BOOLEAN` to `VARCHAR`/`DECIMAL`/`BIGINT`)

### Primary & Foreign Keys

Queries `information_schema.table_constraints` + `key_column_usage` for PKs, applies them via `Type.ReplaceTableKeys`. Exposes `GetForeignKeys()` for FK discovery. Power BI uses these to auto-create relationships.

## Supported Types

The DuckDB types mapped by this sample are listed below. This is the set covered by `TypeInfo.pqm` and `SqlGenerator.pqm` for DuckDB; it is not the limit of what ADBC or `SqlView.Generator` can support. Connectors for other backends will map a different set based on their type system.

BOOLEAN, TINYINT, SMALLINT, INTEGER, BIGINT, HUGEINT, FLOAT, DOUBLE, DECIMAL, DATE, TIME, TIMESTAMP, TIMESTAMP WITH TIME ZONE, VARCHAR, CHAR, BLOB, BINARY, UUID, JSON, INTERVAL, ARRAY, STRUCT, MAP

## Using This as a Template

To adapt this sample for a different FlightSQL-backed database, the main swap-out points are:

| File                     | What to change                                                                                                                                                |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DuckDb.pq`              | Connector name, `DataSource.Kind`, user-facing parameters and credential handling, default URI scheme, and the options record passed to `Adbc.Connection`.    |
| `FlightSqlAdbcConfig.pqm`| Server-specific ADBC metadata: `Name`, catalog/schema support flags, identifier quoting, supported table types. Driver location and entry point stay the same.|
| `SqlGenerator.pqm`       | Replace DuckDB dialect rules with your database's: type facets, LIMIT/OFFSET syntax, function remapping, typed literal formats, supported cast rules.         |
| `TypeInfo.pqm`           | Replace DuckDB native-type to M-type mappings with your database's type system.                                                                               |
| `SqlGeneratorCommon.pqm` | Typically reused as-is. This is the shared SQL92 base.                                                                                                        |
| `resources.resx`         | Update display strings (connector name, descriptions, error messages).                                                                                        |
| `Tests/`                 | Point credentials and parameter queries at your server; update DatasourceSpecific tests to match your dialect's supported features.                           |

## Testing

Tests follow the [PQ SDK Test Framework](../../testframework/tests/PQSDKTestSuites.md), run via `pqtest.exe` (see [PQTest docs](https://learn.microsoft.com/power-query/sdk-tools/pqtest-overview)). This sample reuses the shared **Sanity** and **Standard** suites from `testframework/tests/TestSuites/` and adds DuckDB-specific tests under `Tests/TestSuites/DatasourceSpecific/`. See [Running Tests with VS Code](Tests/RunDuckDbTestsWithVSCodeGuide.md) for live results in Test Explorer.

Tests run against a DuckDB FlightSQL server hosted by [SQLFlite](https://github.com/voltrondata/sqlflite), an open source Flight SQL server image from Voltron Data. The test setup uses the published Docker image (`voltrondata/sqlflite:latest`) running locally on `localhost:31337` with the container's default credentials (`sqlflite_username` / `sqlflite_password`); change these in `Tests/Credentials/duckdb_cred.json` if you override the container defaults.

For example, to start the container with TLS disabled:

```powershell
docker run --name sqlflite --detach --rm --tty --init --publish 31337:31337 --env TLS_ENABLED="0" --env SQLFLITE_PASSWORD="sqlflite_password" --env PRINT_QUERIES="1" --pull missing voltrondata/sqlflite:latest
```

For the full set of container options (TLS, JWT auth, custom data, etc.), see the [sqlflite README](https://github.com/voltrondata/sqlflite/blob/main/README.md).

See [Test Data Setup](Tests/TestSuites/Setup/readme.md) for the full container setup, data loading script, and table inventory.

- [Running Tests with VS Code](Tests/RunDuckDbTestsWithVSCodeGuide.md): recommended approach using Test Explorer
- [Running Performance Tests](Tests/RunDuckDbPerfTestsGuide.md): performance testing with PQPerf

## Building

```powershell
dotnet build DuckDb.proj
```

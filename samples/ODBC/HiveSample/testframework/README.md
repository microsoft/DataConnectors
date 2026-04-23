# HiveSample – Power Query SDK Test Framework

Tests follow the [Power Query SDK test framework](https://learn.microsoft.com/en-us/power-query/sdk-testframework/test-framework) (PQ/PQOut format).

## Test execution commands

PQTest provides multiple commands for testing:

- **`run-compare`** (recommended): Latest command for regression testing with parameter queries
- **`compare`**: Legacy command (still supported, functionally equivalent)
- **`run-test`**: Runs test input from query/settings, with optional filters and TRX output

This guide uses `run-compare`. See [PQTest documentation](https://learn.microsoft.com/en-us/power-query/sdk-tools/pqtest-run-compare) for full command reference.

## Settings file format

All `.settings` files use standard JSON with these fields:

```json
{
  "ExtensionPaths": ["path/to/extension.mez"],
  "ParameterQueryFilePath": "path/to/query.parameterquery.pq",
  "QueryFilePath": "path/to/test.query.pq",
  "FailOnMissingOutputFile": false
}
```

- **ExtensionPaths**: Array of paths to connector `.mez` files
- **ParameterQueryFilePath**: Optional parameter query that runs first to fetch data
- **QueryFilePath**: Test query file (typically a function taking the parameter query result)
- **FailOnMissingOutputFile**: If `false`, auto-generates `.pqout` baseline on first run; if `true`, fails if baseline doesn't exist

## Directory layout

```
testframework/
  ConnectorConfigs/
    HiveSample/
      ParameterQueries/           ← connector-specific data retrieval queries
      Settings/                   ← one .settings file per test
  Tests/
    Sanity/                       ← connection / schema smoke tests
    Standard/
      Filter/
      GroupBy/
      Join/
      Select/
      Sort/
```

## Prerequisites

1. **Power Query SDK** VS Code extension installed (provides `PQTest.exe`).
2. A running Hive LLAP instance with the `foodmart` database and the `customer` / `sales_fact` tables.
3. The connector built: `bin/AnyCPU/Debug/HiveSample.mez` must exist.

## One-time setup

### 1 – Update the parameter queries

Open each file under `ConnectorConfigs/HiveSample/ParameterQueries/` and replace the host/port with your Hive instance:

```m
Source = HiveSample.Contents("<YOUR_HOST>", <YOUR_PORT>),
```

### 2 – Set credentials

Before running tests, credentials must be set for the connector so PQTest can authenticate with your Hive instance.

```powershell
$PQTest    = "<path-to-PQTest.exe>"
$Extension = "bin\AnyCPU\Debug\HiveSample.mez"
$AnyPQ     = "testframework\ConnectorConfigs\HiveSample\ParameterQueries\HiveSampleCustomer.parameterquery.pq"

# Generate a credential template
& $PQTest credential-template -e $Extension -q $AnyPQ --prettyPrint --authenticationKind UsernamePassword

# Fill in the template, save as hive_cred.json, then store credentials
Get-Content hive_cred.json | & $PQTest set-credential -e $Extension -q $AnyPQ
```

See [PQTest credentials documentation](https://learn.microsoft.com/en-us/power-query/sdk-tools/pqtest-credentials) for details.

## Running the tests

**IMPORTANT**: All commands must be run from the project root (`HiveSample/` directory) so relative paths resolve correctly:

```powershell
cd C:\dev\power-query\DataConnectors\samples\ODBC\HiveSample
```

Use `PQTest.exe run-compare` (the current standard):

### Run a single test

```powershell
$PQTest    = "<path-to-PQTest.exe>"
$Extension = "bin\AnyCPU\Debug\HiveSample.mez"

& $PQTest run-compare `
    -e  $Extension `
    -pa "testframework\ConnectorConfigs\HiveSample\ParameterQueries\HiveSampleCustomer.parameterquery.pq" `
    -q  "testframework\Tests\Sanity\HiveSampleRowCount.query.pq"
```

### Run all tests via a settings file

```powershell
$PQTest = "<path-to-PQTest.exe>"

& $PQTest run-compare -sf "testframework\ConnectorConfigs\HiveSample\Settings\HiveSampleRowCount.settings"
```

### Run all tests by looping over every settings file

```powershell
$PQTest = "<path-to-PQTest.exe>"

Get-ChildItem "testframework\ConnectorConfigs\HiveSample\Settings\*.settings" | ForEach-Object {
    Write-Host "Running $($_.Name) ..."
    & $PQTest run-compare -sf $_.FullName
}
```

### Run in mock mode (no ODBC driver required)

These settings use mock parameter queries that return in-memory tables, so they
validate M transforms without connecting to Hive.

```powershell
$PQTest = "<path-to-PQTest.exe>"

& $PQTest run-compare -sf "testframework\ConnectorConfigs\HiveSample\Settings\HiveSampleFilterByState.mock.settings"
& $PQTest run-compare -sf "testframework\ConnectorConfigs\HiveSample\Settings\HiveSampleJoin.mock.settings"
```

Use mock mode for quick logic regression checks. Use the non-mock settings to
validate real connector behavior (credentials, driver, and folding).

### Run with query-folding diagnostics

Add `-dc "Odbc"` to capture the generated SQL:

```powershell
& $PQTest run-compare `
    -e  $Extension `
    -pa "testframework\ConnectorConfigs\HiveSample\ParameterQueries\HiveSampleCustomer.parameterquery.pq" `
    -q  "testframework\Tests\Standard\Filter\HiveSampleFilterByState.query.pq" `
    -dc "Odbc"
```

### Alternative: Using `compare` command (legacy)

The older `compare` command works identically to `run-compare`:

```powershell
& $PQTest compare -e $Extension -q "testframework\Tests\Sanity\HiveSampleRowCount.query.pq" -pa "testframework\ConnectorConfigs\HiveSample\ParameterQueries\HiveSampleCustomer.parameterquery.pq"
```

## First run and output files

On the first run each test produces a `.query.pqout` sibling file next to the `.query.pq` file (because `FailOnMissingOutputFile` is `false`). Subsequent runs compare the live output against that baseline. Commit the `.pqout` files to source control once the output is verified.

For query-folding tests with diagnostics, a `.odbc.diagnostics` file is also created containing the generated SQL statements.

## Test inventory

| Suite    | Test file                                  | What it checks                                  |
|----------|--------------------------------------------|-------------------------------------------------|
| Sanity   | `HiveSampleRowCount.query.pq`              | Table is reachable; returns a row count         |
| Sanity   | `HiveSampleFirstN.query.pq`               | At least one record can be read                 |
| Sanity   | `HiveSampleSchema.query.pq`               | Column names and types are stable               |
| Standard | `Filter/HiveSampleFilterByState.query.pq`  | WHERE predicate folds to SQL                    |
| Standard | `Sort/HiveSampleSortByLastName.query.pq`   | ORDER BY folds to SQL                           |
| Standard | `Select/HiveSampleSelectColumns.query.pq`  | Column projection folds to SQL                  |
| Standard | `GroupBy/HiveSampleGroupByState.query.pq`  | GROUP BY + COUNT aggregation folds to SQL       |
| Standard | `Join/HiveSampleJoin.query.pq`             | INNER JOIN across customer + sales_fact tables  |

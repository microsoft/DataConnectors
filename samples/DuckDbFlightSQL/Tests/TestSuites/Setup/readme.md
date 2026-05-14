# DuckDB FlightSQL Server Setup & Test Data Loading

## Prerequisites

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) installed and running
- Test data CSV files from the [DataConnectors test framework](../../../../../testframework/data):
  - `nyc_taxi_tripdata.csv`
  - `nyc_taxi_trip_date_data.csv`
  - `taxi+_zone_lookup.csv`
  - `misc_table.csv`

## Step 1: Start the SQLFlite Docker Container

Follow the instructions in the [sqlflite README](https://github.com/voltrondata/sqlflite#option-1---running-from-the-published-docker-image) to start a DuckDB FlightSQL server.

For local testing with TLS disabled it would look something like this:

```powershell
docker run --name sqlflite --detach --rm --tty --init --publish 31337:31337 --env TLS_ENABLED="0" --env SQLFLITE_PASSWORD="sqlflite_password" --env PRINT_QUERIES="1" --pull missing voltrondata/sqlflite:latest
```

Verify it's running:

```powershell
docker ps --filter name=sqlflite
```

## Step 2: Load Test Data

Run the data loading script, passing the path to the directory containing the CSV files:

```powershell
cd Tests/TestSuites/Setup
./load_test_data.ps1 -DataDir "<path-to-DataConnectors>/testframework/data"
```

This script:

1. Copies 4 CSV files into the Docker container
2. Creates 7 tables and 1 view with varied DuckDB types (TINYINT, UTINYINT, SMALLINT, USMALLINT, INTEGER, UBIGINT, DECIMAL, BOOLEAN, TIMESTAMP, DATE, VARCHAR, HUGEINT, UUID, JSON, ARRAY, STRUCT, BLOB)
3. Loads the data and verifies row counts

### Tables Created

| Table             | Rows   | Description                                                                                             |
| ----------------- | ------ | ------------------------------------------------------------------------------------------------------- |
| `NycTaxiData`     | 10,000 | Trip data with mixed types (TINYINT, TIMESTAMP, BOOLEAN, DECIMAL, etc.)                                 |
| `NycTaxiDateData` | 10,000 | Trip data with UBIGINT and DATE columns                                                                 |
| `TaxiZoneLookup`  | 265    | Zone reference data (USMALLINT, VARCHAR)                                                                |
| `misc_table`      | 1      | Mixed precision types (DECIMAL(38,18), DECIMAL(12,6), SMALLINT)                                         |
| `TEXT_SAMPLES`    | 1      | Text operation samples (VARCHAR(255))                                                                   |
| `ExtendedTypes`   | 1      | Extended scalar types (HUGEINT, UUID, JSON, BLOB)                                                       |
| `NestedTypes`     | 1      | Nested/complex types (ARRAY, STRUCT)                                                                    |
| `NycTaxiSummary`  | 10,000 | View over NycTaxiData (RecordID, VendorID, fare_amount, tip_amount, total_amount, lpep_pickup_datetime) |

## Step 3: Verify Setup

After the script completes, you should see:

```text
=== All tables loaded and verified successfully! ===
```

You can also verify by running the functional test suite. See [Running DuckDB Tests with VS Code](../../RunDuckDbTestsWithVSCodeGuide.md) for the recommended approach using the VS Code Test Explorer.

Alternatively, run tests manually with PQTest:

```powershell
cd Tests/Settings
& '<path-to-SdkTools>\tools\PQTest.exe' compare --extension ..\..\bin\AnyCPU\Debug\DuckDb.mez --settingsFile duckdbsanitysettings.testsettings.json -p
```

## Connection Details

| Setting  | Value               |
| -------- | ------------------- |
| Host     | `localhost:31337`   |
| TLS      | Disabled            |
| Username | `sqlflite_username` |
| Password | `sqlflite_password` |
| Database | `TPC-H-small`       |
| Schema   | `main`              |

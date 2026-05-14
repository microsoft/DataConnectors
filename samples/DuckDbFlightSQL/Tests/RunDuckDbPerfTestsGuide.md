# Running DuckDB Performance Tests with PQPerf

This guide explains how to run the DuckDB FlightSQL connector performance tests using the **PQPerf** command-line tool from the Power Query SDK Tools package. These tests measure query evaluation throughput over the NYC Taxi dataset (10,000 rows) via the ADBC/FlightSQL transport.

## Prerequisites

1. **PQPerf.exe** — included in the `Microsoft.PowerQuery.SdkTools` NuGet package under the `tools/` folder.
2. **Built connector** — ensure `DuckDb.mez` exists at `bin/AnyCPU/Debug/DuckDb.mez`. Build it by running from the repo root:
   ```powershell
   dotnet build DuckDb.proj
   ```
3. **Credentials** — set up DuckDB connector credentials via the **Power Query: Set Credential** VS Code command. The connector uses `UsernamePassword` authentication.
4. **Test data** — a `sqlflite` Docker container must be running on `localhost:31337` with the test data loaded. See [Test Data Setup](#test-data-setup) below.

## Test Data Setup

Start the `sqlflite` Docker container, then run the data loading script:

```powershell
cd Tests/TestSuites/Setup
./load_test_data.ps1 -DataDir "<path-to-DataConnectors>/testframework/data"
```

This creates 7 tables and 1 view in the `TPC-H-small` database:

| Table             | Rows   | Description                                                    |
| ----------------- | ------ | -------------------------------------------------------------- |
| `NycTaxiData`     | 10,000 | Trip data with mixed types (TIMESTAMP, DECIMAL, BOOLEAN, etc.) |
| `NycTaxiDateData` | 10,000 | Trip data with DATE columns                                    |
| `TaxiZoneLookup`  | 265    | Zone reference data                                            |
| `misc_table`      | 1      | Mixed precision types for edge-case testing                    |
| `TEXT_SAMPLES`    | 1      | Text operation samples                                         |
| `ExtendedTypes`   | 1      | Extended scalar types (HUGEINT, UUID, JSON, BLOB)              |
| `NestedTypes`     | 1      | Nested/complex types (ARRAY, STRUCT)                           |
| `NycTaxiSummary`  | 10,000 | View over NycTaxiData                                          |

## Performance Settings

The test configuration is in `Tests/PerfSettings/perfSettings.json`:

### Key Configuration Fields

| Field              | Description                                                 |
| ------------------ | ----------------------------------------------------------- |
| `ExtensionPaths`   | Path to the DuckDB `.mez` connector file                    |
| `WarmupCount`      | Number of warmup iterations before measurement (default: 2) |
| `RunCount`         | Number of measured iterations (default: 3)                  |
| `EvaluatorMode`    | Evaluation mode — `SinglePartition` for these tests         |
| `ExpectedRowCount` | Expected number of rows returned by the query               |

## Test Scenario

| Scenario              | Protocol         | Rows   | Query File                                    |
| --------------------- | ---------------- | ------ | --------------------------------------------- |
| Duck Db Query NycTaxi | ADBC (FlightSQL) | 10,000 | `TestSuites/PerfTests/DuckDbNycTaxi.query.pq` |

## Running Tests

Open a PowerShell terminal and navigate to the perf settings folder:

```powershell
$PQPerfExe = "<path-to-SdkTools>\tools\PQPerf.exe"
cd Tests\PerfSettings
```

### Run the perf test

```powershell
& $PQPerfExe run-perf -sf .\perfSettings.json
```

## Sample Output

```text
  - Perf Runs:
    - Name: Duck Db Query NycTaxi
    - Query File Path: ../TestSuites/PerfTests/DuckDbNycTaxi.query.pq
    - Evaluator Mode: SinglePartition
    - Expected Row Count: 10000
      - Warmups:
        [##################################################] 10000/10000 X.XXs
        - Run: 1, Elapsed Time: 00:00:XX.XXXXXXX, Returned Row Count: 10000
        [##################################################] 10000/10000 X.XXs
        - Run: 2, Elapsed Time: 00:00:XX.XXXXXXX, Returned Row Count: 10000

      - PerfRuns:
        [##################################################] 10000/10000 X.XXs
        - Run: 1, Elapsed Time: 00:00:XX.XXXXXXX, Returned Row Count: 10000
        [##################################################] 10000/10000 X.XXs
        - Run: 2, Elapsed Time: 00:00:XX.XXXXXXX, Returned Row Count: 10000
        [##################################################] 10000/10000 X.XXs
        - Run: 3, Elapsed Time: 00:00:XX.XXXXXXX, Returned Row Count: 10000

    - Average Evaluation Result:
      - Row Count: 10000
      - Average Duration: 00:00:XX.XXXXXXX
      - Average Working Set: XXXXXXXXX
      - Average Total Processor Time: 00:00:XX.XXXXXXX

  - Summary:
    - ScenarioName: Duck Db Query NycTaxi
    - Row Count: 10000
    - Status: Success
    - Average Duration: 00:00:XX.XXXXXXX
```

## More Information

- [Test Data Setup](TestSuites/Setup/readme.md) — Docker container setup and data loading

# Running DuckDB Tests with VS Code

This guide explains how to run DuckDB connector tests using the **PQTest VS Code Test Explorer integration** provided by the Power Query SDK extension. This feature allows you to discover, run, and debug tests directly from the VS Code UI.

## Prerequisites

1. **DuckDB FlightSQL server** running on `localhost:31337` with test data loaded. See [Test Data Setup](TestSuites/Setup/readme.md) for instructions.
2. **Power Query SDK extension** installed in VS Code.

## Setup

1.  **Open the Connector Folder:**
    - Open the `DuckDb` folder as your **root workspace** in VS Code.

2.  **Configuration:**
    - The folder should be configured with a `.vscode/settings.json` file that points to:
      - **Extension Path:** `bin/AnyCPU/Debug/DuckDb.mez`
      - **Settings File:** `./Tests/Settings`

3.  **Build:**
    - Build the connector so the `.mez` file exists at the expected path:
      ```powershell
      dotnet build DuckDb.proj
      ```

4.  **Credentials:**
    - Set up credentials using the **Power Query: Set Credential** command in VS Code. See [Set Credential documentation](https://learn.microsoft.com/en-us/power-query/power-query-sdk-vs-code#set-credential) for details.
    - Use `UsernamePassword` authentication with the credentials from the [Connection Details](TestSuites/Setup/readme.md#connection-details).

## Running Tests

1.  Open the **Test Explorer** view in VS Code.
2.  You will see the settings files located in `Tests/Settings`:
    - `DuckDbSanitySettings` — basic connectivity and schema tests
    - `DuckDbStandardSettings` — full functional and query folding test suite
    - `DuckDbDatasourceSpecificSettings` — DuckDB-specific tests
3.  Click the "Run" icon to execute tests.

## Running Tests from the Command Line

You can also run tests using PQTest directly:

```powershell
cd Tests/Settings
& '<path-to-SdkTools>\tools\PQTest.exe' compare --extension ..\..\bin\AnyCPU\Debug\DuckDb.mez --settingsFile duckdbstandardsettings.testsettings.json -p
```

## More Information

- [Test Data Setup](TestSuites/Setup/readme.md) — Docker container setup and data loading
- [Running Performance Tests](RunDuckDbPerfTestsGuide.md) — performance testing with PQPerf

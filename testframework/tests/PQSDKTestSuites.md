# PQ SDK Test Framework - Test Suites

The PQ SDK Test Framework consists of prebuilt test suite to easily validate any extension connectors. The test framework is built to run using the `pqtest.exe compare` command and tests in PQ/PQOut format. Please review the documentation from the link [aka.ms/PowerQuerySDKDocs](https://aka.ms/PowerQuerySDKDocs) for more information on running tests with PQTest.exe in PQ/PQOut format.

The test framework consists of the following:

**TestSuites folder**: This folder contains all the pre-built tests for testing a connector. This folder contains two sets of tests present under Sanity & Standard folders:
- **Sanity folder**: The sanity tests validate that the tests are able to connect to the data source and the test tables with correct schema exist in the datasource. There are also tests that validate the rowcount and data of NYCTaxiGreen and TaxiZoneLookup tables in the datasource.
- **Standard folder**: The standard sets contain various tests that need to validate the connector. There are tests to test all the datatypes, Math, Date, Time, Text functions and operators. There are tests to validate joins between two tables as well.

**ConnectorConfigs folder**: This folder contains a folder with the connector name for connector to be tested which contains ParameterQueries & Settings. Samples are provided for snowflake, bigquery, spark and generic connectors. 
  - **ParameterQueries folder:** It will be present under a folder with the connector name and contains the parameter query file(s) which are M queries to connect to the data source and retrieve the NycTaxiGreen & TaxiZoneLookup tables.
  - **Settings folder:** It contains folders with the name of the data source extension connectors where the test folder and the parameter query file locations are specified.

**RunPQSDKTestSuites.ps1:** This script will execute all PQ/PQOut tests present in the Sanity & Standard folders and generate the results.       

**RunPQSDKTestSuitesSettings.json:** This json file can be used to provide all the arguments that can be passed to RunPQSDKTestSuites.ps1.

**RunPQSDKTestSuitesSettingsTemplate.json:** This json file contains all the arguments that you can set in `RunPQSDKTestSuitesSettings.json` file.

## Initial Setup

To ensure that you can run these pre-built tests, the below pre-requisites must be completed before running the tests:

- Clone the DataConnectors repo.
- Load the provided test data in the data source.
- Set the PQTest.exe and Extension paths in the RunPQSDKTestSuitesSettings.json file.
- Update parameter queries and settings file with the details specific to your data source extension connector.
- Set the credentials for your extension connector.
- Validate the test data is setup correctly by running the Sanity Tests.

### Clone the DataConnectors repo:

Clone the [DataConnectors repo](https://github.com/microsoft/DataConnectors). Refer the
[DataConnectors README](https://github.com/microsoft/DataConnectors/blob/master/README.md) for information
on Custom Connectors built with the Power Query SDK.

### Test Data Loading:

The test data is provided in the form of csv along with the schema defintion. This should be loaded as `NycTaxiGreen` and `TaxiZoneLookup` tables to your data source ensuring that the schema corresponds to the datatypes defined in your data source. Refer to `testframework\data\PQSDKTestData.md` for further information.

### Set the PQTest.exe and Extension paths in the RunPQSDKTestSuitesSettings.json file:

- Navigate to the `testframework\tests` and open the the `RunPQSDKTestSuitesSettings.json` file in cloned repo folder and set the following values:

  ```
  // Set the paths for PQTest.exe wand Extension in the config
  "PQTestExePath":"<Replace with the path to PQTest.exe. Ex: 'C:\\Users\\ContosoUser\\.vscode\\extensions\\powerquery.vscode-powerquery-sdk-0.2.3-win32-x64\\.nuget\\Microsoft.PowerQuery.SdkTools.2.114.4\\tools\\PQTest.exe'>",
  $Extension = "<Replace with path to the extension mez file Ex: C:\\dev\\ConnectorName\\ConnectorName.mez'>"
  ```

  Note: You can find further information about all the variables that you can set in `RunPQSDKTestSuitesSettings.json` file in the template `testframework\tests\RunPQSDKTestSuitesSettingsTemplate.json` provided.

### Update parameter queries and settings file with the details specific to your data source extension connector:

- Running the powershell script `.\RunPQSDKTestSuites.ps1` will create the parameter queries and test Settings by creating a folder with the `<extension name>` and `Settings` & `ParameterQueries` folders under it.
  ```
  - testframework\tests\ConnectorConfigs\<Extension Name>\ParameterQueries
  - testframework\tests\ConnectorConfigs\<Extension Name>\Settings

  Ex: For an connector named Contoso the paths will be as below:
  - testframework\tests\TestSuites\Contoso\ParameterQueries
  - testframework\tests\TestSuites\Contoso\Settings
  ```
  Note: Please update the parameter query file(s) generated by replacing with the M query to connect to your data source and retrieve the NycTaxiGreen & TaxiZoneLookup tables.

- Alternatively, to manually create the parameter query file(s) and settings file(s)for your data source perform the below steps:

  - Navigate to the folder under the cloned repo folder: `testframework\tests\ConnectorConfigs`
  - Make a copy of the "generic" folder and rename it to the extension name
  - Open each file under the `ParameterQuries` folder and update the M queries as the instructions provided in the file
  - Open each file under the `Settings` folder and update the settings file to point to the correct parameter query file

### Set the credentials for your extension connector:

- Ensure the credentials are setup for your connector following the instructions here: https://learn.microsoft.com/en-us/power-query/power-query-sdk-vs-code#set-credential 
- Alternatively, use this `credential-template` command to generate a credential template in json format for your connector that can be passed into the `set-credential` command. Refer the [credential-template](https://dev.azure.com/powerbi/Power%20Query/_git/PowerQuerySdkTools?path=/Tools/PQTest/pqtest.md&_a=preview&version=GBmain&anchor=credential-template)  section in the pqtest.md file on the usage to set up the credentials for your connector.

  ```
  <Path to PQText.exe> credential-template -e <Path to Extension.exe> -q "<Replace with path to any parameter query file>" --prettyPrint --authenticationKind <Specify the authentication kind (Anonymous, UsernamePassword, Key, Windows, OAuth2)>

  Example:
  C:\Users\ContosoUser\.vscode\extensions\powerquery.vscode-powerquery-sdk-0.2.3-win32-x64\.nuget\Microsoft.PowerQuery.SdkTools.2.114.4\tools\PQTest.exe credential-template -e "C:\dev\Contoso\Contoso.mez" -q "C:\dev\DataConnectors\testframework\tests\TestSuites\ParameterQueries\Contoso\Contoso.parameterquery.pq" --prettyPrint --authenticationKind UsernamePassword
  ```

  Take the output from the above command and replace the Username and Password values with correct credentials and save  it as json file (Ex: contoso_cred.json).

- Then, use this `set-credential` command store credentials that will be used by the `compare` commands to run the tests. Using the existing powershell window, set the credentials for your extension using the json credential file generated in the previous step. Refer the [set-credential](https://dev.azure.com/powerbi/Power%20Query/_git/PowerQuerySdkTools?path=/Tools/PQTest/pqtest.md&_a=preview&version=GBmain&anchor=set-credential) section in pqtest.md file on the usage to set up the credentials for your connector.

  ```
  Get-Content "<Replace with path to the json credential file>" | & $PQTestExe set-credential -e "$Extension" -q "<Replace with the path to any parameter query file>

  Example:
  Get-Content "C:\dev\Misc\contoso_cred.json" | C:\Users\ContosoUser\.vscode\extensions\powerquery.vscode-powerquery-sdk-0.2.3-win32-x64\.nuget\Microsoft.PowerQuery.SdkTools.2.114.4\tools\PQTest.exe  set-credential -p -e "$Extension" -q "C:\dev\DataConnectors\testframework\tests\TestSuites\Contoso\ParameterQueries\Contoso.parameterquery.pq"

  ```

### Validate the test data is setup correctly by running the Sanity Tests:

To ensure that the changes are working and the data setup is done correctly, run Sanity Tests as below:

- Run the Sanity Tests using the below commands:

```
# Run the Sanity Tests
.\RunPQSDKTestSuites.ps1 -TestSettingsList SanitySettings.json

Example:
PS C:\dev\DataConnectors\testframework\tests\TestSuites> .\RunPQSDKTestSuites.ps1 -TestSettingsList SanitySettings.json

# Output
----------------------------------------------------------------------------------------------
PQ SDK Test Framework - Test Execution - Test Results Summary for Extension: Contoso.pqx
----------------------------------------------------------------------------------------------

TestFolder  TestName                        OutputStatus TestStatus Duration
----------  --------                        ------------ ---------- --------
Sanity\Taxi AllTypes.query.pq                          Passed     00:00:00.0227976
Sanity\Taxi AllTypesRowCount.query.pq                  Passed     00:00:00.0001734
Sanity\Taxi AllTypesSchema.query.pq                    Passed     00:00:00.0001085
Sanity\Zone AllTypesZone.query.pq                      Passed     00:00:00.0010058
Sanity\Zone AllTypesZoneRowCount.query.pq              Passed     00:00:00.0001786
Sanity\Zone AllTypesZoneSchema.query.pq                Passed     00:00:00.0000920

----------------------------------------------------------------------------------------------
Total Tests: 6 | Passed: 6 | Failed: 0 | Total Duration: 00d:00h:00m:01s
----------------------------------------------------------------------------------------------

```

## Run the Sanity & Standard Tests

### Run using RunPQSDKTestSuites.ps1 utility

To run all the Sanity & Standard Tests or a set of tests defined by settings file, use the `RunPQSDKTestSuites.ps1` utility present in the `testframework\tests\TestSuites` directory. Using the same PowerShell window, run the below command to execute the tests:

```
# Run all the Sanity & Standard Tests
.\RunPQSDKTestSuites.ps1

Example:
PS C:\dev\DataConnectors\testframework\tests\TestSuites> .\RunPQSDKTestSuites.ps1
```

To know more about the `RunPQSDKTestSuites.ps1` utility, run the `Get-Help` command as below:

```
Get-help .\RunPQSDKTestSuites.ps1 -Detailed
Example:
PS C:\dev\DataConnectors\testframework\tests\TestSuites> Get-help .\RunPQSDKTestSuites.ps1 -Detailed
```

### Run using the PQTest.exe

Use the below command in the same PowerShell window to run a particular tests directly using PQTest.exe:

```
<Path to PQText.exe> compare -p -e $Extension -pa <Replace with path to the parameter query> -q <Replace with the the path to test query>

Example:
 C:\Users\ContosoUser\.vscode\extensions\powerquery.vscode-powerquery-sdk-0.2.3-win32-x64\.nuget\Microsoft.PowerQuery.SdkTools.2.114.4\tools\PQTest.exe compare -p -e "$Extension" -pa "C:\dev\DataConnectors\testframework\tests\TestSuites\Contoso\ParameterQueries\Contoso.parameterquery.pq" -q "C:\dev\DataConnectors\testframework\tests\TestSuites\Standard\Datatypes\Cast.query.pq"

```

Please review the documentation in [pqtest.md ](https://dev.azure.com/powerbi/Power%20Query/_git/DataConnectors?path=/PowerQuerySDKTestFramework/docs/PowerQuerySdkTools/Tools/PQTest/pqtest.md&_a=preview&version=GBmaster) in the DataConnectors repo for more information on running tests with PQTest.exe.

## Running query folding tests

The tests under any Sanity & Standard Tests can be run to validate the query folding. Run the test first time to generate additional diagnostics output file under `testframework\tests\<Extension Name>\Diagnostics\` folder. Subsequent runs will validate the output generated with the diagnostics output file.

### Run query folding tests using RunPQSDKTestSuites.ps1 utility

```
// Validate Query folding the Sanity & Standard Tests
.\RunPQSDKTestSuites.ps1 -ValidateQueryFolding

Example:
PS C:\dev\DataConnectors\testframework\tests\TestSuites> .\RunPQSDKTestSuites.ps1 -ValidateQueryFolding
```
Note: Alternatively, specify `ValidateQueryFolding=True` in the   `testframework\tests\TestSuite\RunPQSDKTestSuitesSettings.json` file.

### Run query folding tests using the PQTest.exe

```
<Path to PQText.exe> compare -p -e $Extension -pa <Replace with path to the parameter query> -q <Replace with the the path to test query> -dfp <Replace with path to the diagnostic output file>

Example:
 C:\Users\ContosoUser\.vscode\extensions\powerquery.vscode-powerquery-sdk-0.2.3-win32-x64\.nuget\Microsoft.PowerQuery.SdkTools.2.114.4\tools\PQTest.exe compare -p -e "$Extension" -pa "C:\dev\DataConnectors\testframework\tests\TestSuites\ParameterQueries\Contoso\Contoso.parameterquery.pq" -q "C:\dev\DataConnectors\testframework\tests\TestSuites\Standard\Datatypes\Cast.query.pq" -dfp "C:\dev\DataConnectors\testframework\tests\TestSuites\Contoso\Diagnostics"

```

## Creating custom tests

Below are sample instructions on how custom tests can be added:
- Create a `Custom` folder under `testframework\tests\TesSuites`. 
- Create a PQ file with the M Query that needs to be tested and place it in the `Custom` directory. 
- Create a settings file `CustomSettings.json` under `testframework\tests\ConnectorConfigs\<Connector Name>\Settings` folder. Add the paths for test folder `"QueryFilePath": "TestSuites/Custom"` and the parameter query file `"ParameterQueryFilePath": "ParameterQueries/<Connector Name>/<Connector Name>.parameterquery.pq"` in it.
- Run the test first time to generate the PQOut output file. 
- Subsequent runs will validate the output generated with the PQOut output file. 
- Please review the documentation in [pqtest.md](https://dev.azure.com/powerbi/Power%20Query/_git/DataConnectors?path=/PowerQuerySDKTestFramework/docs/PowerQuerySdkTools/Tools/PQTest/pqtest.md&_a=preview&version=GBmaster) in the DataConnectors repo for more information on creating new tests using the compare command.

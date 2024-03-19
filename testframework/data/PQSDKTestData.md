# PQ SDK Test Framework - Test Data

The test data used for PQ SDK Test framework is a modified version of the **Taxi & Limousine Comission (TLC) green trip
record data** and the **Taxi Zone Lookup table**. The details of the data could be found on the
[TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) page on the NYC Taxi & Limousine
Commission website.

The modified dataset is open for anyone to use under the [CDLA-Permissive-2.0 license](https://cdla.dev/permissive-2-0/). 

## PQ SDK Test Framework - Test Data Details:

The PQ SDK Test Framework dataset contains the below files:

- **nyc_taxi_tripdata.csv** file which contains 10000 rows sampled from the February 2023 green trip data
- **taxi+\_zone_lookup.csv** file which contains 265 rows from the taxi zone lookup table
- **PQSDKTestFrameworkDataSchema.sql** file contains the schema for NyxTaxiGreen and TaxiZoneLookup table

## PQ SDK Test Framework - Test Data Loading

The PQ SDK Test Framework dataset needs to be loaded to the datasource for your extension connector before running the
PQ SDK Testframework Test Suites. The data is provided in convenient csv format so that it can be easily be loaded to
any datasource. The **nyc_taxi_tripdata.csv** and **taxi+\_zone_lookup.csv** files should be respectively loaded into
NyxTaxiGreen and TaxiZoneLookup tables as per the schema specified in the **PQSDKTestFrameworkDataSchema.sql** file.

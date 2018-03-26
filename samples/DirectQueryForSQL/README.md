# Direct Query using SQL Server ODBC
This sample creates an ODBC based custom connector that enables Direct Query for SQL Server.

The code does the following:

* Declares a new data source kind (DirectSQL)
* Builds a `record` containing connection string properties specific to the `SQL Server Native Client 11.0` driver
* Sets credential related connection string properties separately
* Overrides default ODBC capabilities returned by the driver
* Wraps M's built-in ODBC function - `Odbc.DataSource`

Please see the comments in the code for more details.
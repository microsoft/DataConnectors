# Hive LLAP Sample

This connector sample uses the Hive ODBC driver, and is based on the [connector template](../SqlODBC).

The current code uses the [Microsoft Hive ODBC driver](https://www.microsoft.com/en-us/download/details.aspx?id=40886), but was also tested with the [Hortonworks Hive ODBC driver](https://hortonworks.com/downloads/). Other Hive drivers may require different connection string parameters.

To change the driver you wish to use, change the `Config_DriverName` value in `HiveSample.pq`.

> Please note that this sample enables Direct Query, which should only be used with [Hive LLAP](https://cwiki.apache.org/confluence/display/Hive/LLAP) / interactive mode. Power BI Desktop users that wish to connect to Hive LLAP on HD Insight should use the built-in [HDInsight Interactive Query connector](https://docs.microsoft.com/en-us/azure/hdinsight/interactive-query/apache-hadoop-connect-hive-power-bi-directquery) instead of this custom connector.
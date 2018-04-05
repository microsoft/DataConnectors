# Welcome

If you've reached this landing page, it's probably via a new button you clicked in Power BI! We're still getting some final tweaks working on our end to deliver third party connectors to you, but we hope they'll be available soon. Look forward to experience improvements in short order!

# Getting Started with Data Connectors
Data Connectors for Power BI enables users to connect to and access data from your application, service, or data source, providing them with rich business intelligence and robust analytics over multiple data sources. By integrating seamlessly into the Power Query connectivity experience in Power BI Desktop, Data Connectors make it easy for power users to query, shape and mashup data from your app to build reports and dashboards that meet the needs of their organization.

![PBIGetData](blobs/helloworld1.png "Hello World in Get Data")

Data Connectors are created using the [M language](https://msdn.microsoft.com/library/mt211003.aspx). This is the same language used by the Power Query user experience found in Power BI Desktop and Excel 2016. Extensions allow you to define new functions for the M language, and can be used to enable connectivity to new data sources. While this document will focus on defining new connectors, much of the same process applies to defining general purpose M functions. Extensions can vary in complexity, from simple wrappers that essentially just provide "branding" over existing data source functions, to rich connectors that support Direct Query.

Please see the [Data Connector technical reference](docs/m-extensions.md) for more details.

## Quickstart

> **Note:** The steps to enable extensions changed in the June 2017 version of Power BI Desktop.

1. Enable the **Custom data connectors** preview feature in Power BI Desktop (under *File | Options and settings | Custom data connectors*)
2. Restart Power BI Desktop

![Preview Feature](blobs/previewFeature.png)

# TripPin Tutorial
This multi-part tutorial covers the creation of a new data source extension for Power Query. The tutorial is meant to be done sequentially – each lesson builds on the connector created in previous lessons, incrementally adding new capabilities to your connector. 

This tutorial uses a public [OData](http://www.odata.org/documentation/) service ([TripPin](http://services.odata.org/v4/TripPinService/)) as a reference source. Although this lesson requires the use of the M engine’s OData functions, subsequent lessons will use [Web.Contents](https://msdn.microsoft.com/en-us/library/mt260892.aspx), making it applicable to (most) REST APIs.

## Prerequisites

The following applications will be used throughout this tutorial:

* [Power BI Desktop](https://www.microsoft.com/en-us/download/details.aspx?id=45331), May 2017 release or later
* [Power Query SDK for Visual Studio](https://aka.ms/powerquerysdk)
* [Fiddler](http://www.telerik.com/fiddler) - Optional, but recommended for viewing and debugging requests to your REST service

Reviewing the [M Extensibility documentation](../../docs/m-extensions.md) before starting this tutorial is highly recommended.

## Parts 

|Part|Lesson                       |Details|
|----|:----------------------------|:----------------------------------------------------|
|1   |[OData](1-OData)             |Create a simple Data Connector over an OData service |
|2   |[Rest](2-Rest)               |Connect to a REST API that returns a JSON response   | 
|3   |[Nav Tables](3-NavTables)    |Providing a navigation experience for your source    | 
|4   |[Data Source Paths](4-Paths) |How credentials are identified for your data source  | 
|5   |[Paging](5-Paging)           |Read with a paged response from a web service        | 
|6   |[Enforcing Schema](6-Schema) |Enforce table structure and column data types        | 


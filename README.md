# Getting Started with Data Connectors
Data Connectors for Power BI enables users to connect to and access data from your application, service, or data source, providing them with rich business intelligence and robust analytics over multiple data sources. By integrating seamlessly into the Power Query connectivity experience in Power BI Desktop, Data Connectors make it easy for power users to query, shape and mashup data from your app to build reports and dashboards that meet the needs of their organization.

![PBIGetData]

Data Connectors are created using the [M language](https://msdn.microsoft.com/en-us/library/mt211003.aspx). This is the same language used by the Power Query user experience found in Power BI Desktop and Excel 2016. Extensions allow you to define new functions for the M language, and can be used to enable connectivity to new data sources. While this document will focus on defining new connectors, much of the same process applies to defining general purpose M functions. Extensions can vary in complexity, from simple wrappers that essentially just provide "branding" over existing data source functions, to rich connectors that support Direct Query.

Please see the [Data Connector technical reference](docs/m-extensions.md) for more details.

## Quickstart
1. Install the Power Query SDK from the Visual Studio Marketplace
2. Create a new Data Connector project
3. Define your connector logic
4. Build the project to produce a .mez file
5. Create a `C:\Program Files\Microsoft Power BI Desktop\bin\extensions` directory
6. Create a `PQ_ExtensionDirectory` environment variable, set its value to this directory
7. Copy the .mez file into this directory
8. Restart Power BI Desktop 

**Note:** Creating the extensions directory and setting the environment variable (Steps 5 and 6) are temporary. Data Connector extensibility will be offered as a Preview Feature in Power BI Desktop, starting with the June release.

![VSProject]

## Distribution of Data Connectors
Power BI Desktop users can download extension files and place them in a known directory (steps described above). Power BI Desktop will automatically load the extensions on restart.

_We are hard at work finalizing the distribution mechanism so that end users can discover and install data connectors you build. During this preview phase, developers interested in distributing their connectors for use with Power BI can contact us at DataConnectors (at) microsoft.com._

## Additional Links and Resources
* [Data Connector Technical Reference](docs/m-extensions.md)
* [M Library Functions](https://msdn.microsoft.com/en-US/library/mt253322.aspx)
* [M Language Specification](http://pqreference.azurewebsites.net/PowerQueryFormulaLanguageSpecificationAugust2015.pdf)
* [Power BI Developer Center](https://powerbi.microsoft.com/en-us/developers/)

## Hello World Sample
The following code sample defines a simple "Hello World" data source. See the [full sample](samples/HelloWorld) for more information.

![GetData]

<pre style="font-family:Consolas;font-size:13;color:black;background:white;"><span style="color:blue;">section</span><span style="color:green;">&nbsp;</span>HelloWorld;<span style="color:green;">
 
</span>[DataSource.Kind=<span style="color:#a31515;">&quot;HelloWorld&quot;</span>,<span style="color:green;">&nbsp;</span>Publish=<span style="color:#a31515;">&quot;HelloWorld.Publish&quot;</span>]<span style="color:green;">
</span>shared<span style="color:green;">&nbsp;</span><span style="color:#2b91af;">HelloWorld.Contents</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>(optional<span style="color:green;">&nbsp;</span><span style="color:#2b91af;">message</span><span style="color:green;">&nbsp;</span><span style="color:blue;">as</span><span style="color:green;">&nbsp;</span>text)<span style="color:green;">&nbsp;</span>=&gt;<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:blue;">let</span><span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">message</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span><span style="color:blue;">if</span><span style="color:green;">&nbsp;</span>(message<span style="color:green;">&nbsp;</span>&lt;&gt;<span style="color:green;">&nbsp;</span>null)<span style="color:green;">&nbsp;</span><span style="color:blue;">then</span><span style="color:green;">&nbsp;</span>message<span style="color:green;">&nbsp;</span><span style="color:blue;">else</span><span style="color:green;">&nbsp;</span><span style="color:#a31515;">&quot;Hello&nbsp;world&quot;</span><span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:blue;">in</span><span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>message;<span style="color:green;">
 
</span><span style="color:#2b91af;">HelloWorld</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>[<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">Authentication</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>[<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">Implicit</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>[]<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span>],<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">Label</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.LoadString</span>(<span style="color:#a31515;">&quot;DataSourceLabel&quot;</span>)<span style="color:green;">
</span>];<span style="color:green;">
 
</span><span style="color:#2b91af;">HelloWorld.Publish</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>[<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">Beta</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>true,<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">ButtonText</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>{<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.LoadString</span>(<span style="color:#a31515;">&quot;FormulaTitle&quot;</span>),<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.LoadString</span>(<span style="color:#a31515;">&quot;FormulaHelp&quot;</span>)<span style="color:green;">&nbsp;</span>},<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">SourceImage</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>HelloWorld.Icons,<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">SourceTypeImage</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>HelloWorld.Icons<span style="color:green;">
</span>];<span style="color:green;">
 
</span><span style="color:#2b91af;">HelloWorld.Icons</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>[<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">Icon16</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>{<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld16.png&quot;</span>),<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld20.png&quot;</span>),<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld24.png&quot;</span>),<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld32.png&quot;</span>)<span style="color:green;">&nbsp;</span>},<span style="color:green;">
&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="color:#2b91af;">Icon32</span><span style="color:green;">&nbsp;</span>=<span style="color:green;">&nbsp;</span>{<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld32.png&quot;</span>),<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld40.png&quot;</span>),<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld48.png&quot;</span>),<span style="color:green;">&nbsp;</span><span style="font-weight:bold;color:#008800;">Extension.Contents</span>(<span style="color:#a31515;">&quot;HelloWorld64.png&quot;</span>)<span style="color:green;">&nbsp;</span>}<span style="color:green;">
</span>];<span style="color:green;">
</span></pre>

## What You Can Do With a Data Connector
Data Connectors allow you to create new data sources, or customize and extend an existing source. Common use cases include:

- Creating a business analyst friendly view for a REST API
- Providing branding for a source that Power Query supports with an existing connector (such as an OData service, or ODBC driver)
- Implementing an OAuth v2 authentication flow for a SaaS offering
- Exposing a limited/filtered view over your data source to improve usability
- Supporting different authentication modes when creating a [Power BI Content Pack](https://powerbi.microsoft.com/en-us/documentation/powerbi-developer-content-pack-overview/)
- Enabling Direct Query for a data source via an ODBC driver

Currently, Data Connectors are only supported in Power BI Desktop.

### Coming Soon
Data Connectors are currently in preview. We plan to incrementally roll out a number of enhancements prior to general availability, including:

- [ ] File extension changes (.mez to .pqx)
- [ ] Improved tracing and diagnostics for developing Direct Query capable connectors
- [ ] Versioning of extensions, and support for dependencies
- [ ] Improved support for Library extensions (for reusable utility functions)
- [ ] Integration and support for API Connectors for Microsoft Flow and PowerApps
- [ ] Support for Scheduled Refresh via the [On-Premises Data Gateway](https://powerbi.microsoft.com/en-us/documentation/powerbi-gateway-onprem/)
- [ ] Integration with the Office Store
- [ ] Development experience improvements

Please report issues and feature requests through our [Github issues page](https://github.com/Microsoft/DataConnectors/issues).

[VSProject]: blobs/vs2017_project.png "Data Connector projects in Visual Studio"
[GetData]: blobs/helloworld1.png "Hello World in Get Data"
[PBIGetData]: blobs/pbigetdata.png "Get Data dialog in Power BI Desktop"
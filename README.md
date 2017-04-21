# Getting Started with M Extensions
Power BI extensions are created using M (also known as the Power Query Formula Language). This is the same language used by the Power Query (PQ) user experience found in Power BI Desktop (PBID) and Excel 2016. Extensions allow you to define new functions for the M language, and can be used to enable connectivity to new data sources. While this document will focus on defining new connectors, much of the same process applies to defining general purpose M functions. Extensions can vary in complexity, from simple wrappers that essentially just provide "branding" over existing data source functions, to rich connectors that support Direct Query (DQ).

## Quickstart
1. Install the Power Query SDK from the Visual Studio Marketplace (TODO - provide link)
2. Create a new Data Connector project
3. Define your connector logic
4. Build the project to produce a .mez file
5. Set a **PQ_ExtensionDirectory** environment variable, set it to `"c:\program files\microsoft power bi desktop\bin\extensions"`
6. Copy the .mez file in your c:\program files\microsoft power bi desktop\bin\extensions directory
7. Restart Power BI Desktop 

**Note:** Setting the environment variable (Step 5) is temporary. Extensibility can be enabled as a Preview Feature in Power BI Desktop starting the June release.

![VSProject]

## Resources
* [Power Query SDK documentation](docs/m-extensions.md)
* [M Library Functions](https://msdn.microsoft.com/en-US/library/mt253322.aspx)
* [M Language Specification](http://pqreference.azurewebsites.net/PowerQueryFormulaLanguageSpecificationAugust2015.pdf)
* [Power BI Developer Center](https://powerbi.microsoft.com/en-us/developers/)

## Hello World Sample
The following code sample defines a simple "Hello World" data source. See the [full sample](samples/HelloWorld) for more information.

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

[VSProject]: blobs/vs2017_project.png "Data Connector projects in Visual Studio"
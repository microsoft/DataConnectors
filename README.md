# TODO
- [ ] add screenshots of visual studio sdk
- [ ] add hello world sample
- [ ] add links to other docs

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

## M Extension Files (MEZ)
M extensions are bundled in a zip file and given a .mez file extension. These are typically referred to as MEZ files. A MEZ will contain the following files: 
* Script file containing your function and model definition (i.e. MyConnector.m)
* Icons of various sizes (i.e. *.png)
* Resource file(s) containing strings for localization (i.e. resources.resx)

At runtime, Power BI Desktop can load extensions from directory defined by the PQ_ExtensionDirectory environment variable. These applications will attempt to load files with both the .m and .mez format, however, use of a .mez is required if you wish to include icons or localized strings for your extension.


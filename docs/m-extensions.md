**more todo**

## M Extension Files (MEZ)
M extensions are bundled in a zip file and given a .mez file extension. These are typically referred to as MEZ files. A MEZ will contain the following files: 
* Script file containing your function and model definition (i.e. MyConnector.m)
* Icons of various sizes (i.e. *.png)
* Resource file(s) containing strings for localization (i.e. resources.resx)

At runtime, Power BI Desktop can load extensions from directory defined by the `PQ_ExtensionDirectory` environment variable. These applications will attempt to load files with both the .m and .mez format, however, use of a .mez is required if you wish to include icons or localized strings for your extension.


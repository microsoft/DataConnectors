section GithubSample;

//
// OAuth configuration settings
//
// You MUST replace the values below for values for your own application.
// Signin to GitHub and navigate to https://github.com/settings/applications/new.
// Follow the steps and obtain your client_id and client_secret.
// Set your Redirect URI value in your application registration to match the value below.
// Update the values within the "client_id" and "client_secret" files in the project.
// 
// Note: due to incompatibilities with the Internet Explorer control used in Visual Studio,
// you will not be able to authorize a new github application during the OAuth flow. You can workaround
// this by loading your extension in Power BI Desktop, and completing the OAuth flow there. 
// Once the application has been authorized for a given user, then the OAuth flow will work when 
// run in Visual Studio.

client_id = Text.FromBinary(Extension.Contents("client_id"));
client_secret = Text.FromBinary(Extension.Contents("client_secret"));
redirect_uri = "https://preview.powerbi.com/views/oauthredirect.html";
windowWidth = 1200;
windowHeight = 1000;

//
// Exported functions
//
// These functions are exported to the M Engine (making them visible to end users), and associates 
// them with the specified Data Source Kind. The Data Source Kind is used when determining which 
// credentials to use during evaluation. Credential matching is done based on the function's parameters. 
// All data source functions associated to the same Data Source Kind must have a matching set of required 
// function parameters, including type, name, and the order in which they appear. 

[DataSource.Kind="GithubSample", Publish="GithubSample.UI"]
shared GithubSample.Contents = Value.ReplaceType(Github.Contents, type function (url as Uri.Type) as any);

[DataSource.Kind="GithubSample"]
shared GithubSample.PagedTable = Value.ReplaceType(Github.PagedTable, type function (url as Uri.Type) as nullable table);

//
// Data Source definition
//
GithubSample = [
    Authentication = [
        OAuth = [
            StartLogin = StartLogin,
            FinishLogin = FinishLogin,
            Label = Extension.LoadString("AuthenticationLabel")
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

//
// UI Export definition
//
GithubSample.UI = [
    Beta = true,
    ButtonText = { Extension.LoadString("FormulaTitle"), Extension.LoadString("FormulaHelp") },
    SourceImage = GithubSample.Icons,
    SourceTypeImage = GithubSample.Icons
];

GithubSample.Icons = [
    Icon16 = { Extension.Contents("github16.png"), Extension.Contents("github20.png"), Extension.Contents("github24.png"), Extension.Contents("github32.png") },
    Icon32 = { Extension.Contents("github32.png"), Extension.Contents("github40.png"), Extension.Contents("github48.png"), Extension.Contents("github64.png") }
];

//
// Github.Contents - retrieves a single page of data from github and sets a 
// Next link value as meta on the returned json response. We parse the json
// result (which will be a list of records) into a table.
//
Github.Contents = (url as text) =>
    let
        content = Web.Contents(url),
        link = GetNextLink(content),
        json = Json.Document(content),
        table = Table.FromList(json, Splitter.SplitByNothing())
    in
        table meta [Next=link];

Github.PagedTable = (url as text) => Table.GenerateByPage((previous) =>
    let
        // If we have a previous page, get its Next link from metadata on the page.
        next = if (previous <> null) then Value.Metadata(previous)[Next] else null,
        // If we have a next link, use it, otherwise use the original URL that was passed in.
        urlToUse = if (next <> null) then next else url,
        // If we have a previous page, but don't have a next link, then we're done paging.
        // Otherwise retrieve the next page.
        current = if (previous <> null and next = null) then null else Github.Contents(urlToUse),
        // If we got data back from the current page, get the link for the next page
        link = if (current <> null) then Value.Metadata(current)[Next] else null
    in
        current meta [Next=link]);

// This function returns an absolute URL to the next page of data.
// 
// The 'response' parameter typically contains the result of the call to Web.Contents. 
// The 'request' parameter is optional and contains values to formulate the request.
// It is typically used when the next link is a relative URL and needs to be 
// appended to a base URL from the request. Its format is up to the extension author. 
//
// The current implementation is specific to Github, which returns its next link 
// in a "Link" header in the response. The 'request' parameter is not used.
// You will most likely need to replace the logic below with whatever paging
// mechanism is used by your data source.
//
GetNextLink = (response, optional request) =>
    let
        // extract the "Link" header if it exists
        link = Value.Metadata(response)[Headers][#"Link"]?,
        links = Text.Split(link, ","),
        splitLinks = List.Transform(links, each Text.Split(Text.Trim(_), ";")),
        next = List.Select(splitLinks, each Text.Trim(_{1}) = "rel=""next"""),
        first = List.First(next),
        removedBrackets = Text.Range(first{0}, 1, Text.Length(first{0}) - 2)
    in
        try removedBrackets otherwise null;

//
// OAuth2 flow definition
//

StartLogin = (resourceUrl, state, display) =>
    let
        AuthorizeUrl = "https://github.com/login/oauth/authorize?" & Uri.BuildQueryString([
            client_id = client_id,
            scope = "user, repo",
            state = state,
            redirect_uri = redirect_uri])
    in
        [
            LoginUri = AuthorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = windowHeight,
            WindowWidth = windowWidth,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        Parts = Uri.Parts(callbackUri)[Query]
    in
        TokenMethod(Parts[code]);

TokenMethod = (code) =>
    let
        Response = Web.Contents("https://github.com/login/oauth/access_token", [
            Content = Text.ToBinary(Uri.BuildQueryString([
                client_id = client_id,
                client_secret = client_secret,
                code = code,
                redirect_uri = redirect_uri])),
            Headers=[#"Content-type" = "application/x-www-form-urlencoded",#"Accept" = "application/json"]]),
        Parts = Json.Document(Response)
    in
        Parts;

//
// Common code
//

// Calls the getNextPage function until it returns null. 
// Each call to getNextPage expects a table of data to be returned.
// The result of the previous call to getNextPage is passed along to the next call.
// Appends all pages (tables) together into a single result.
// Returns an empty table if the first call to getNextPage returns null.
Table.GenerateByPage = (getNextPage as function) as table =>
    let
        listOfPages = List.Generate(
            () => getNextPage(null),
            (lastPage) => lastPage <> null,
            (lastPage) => getNextPage(lastPage)
        ),
        tableOfPages = Table.FromList(listOfPages, Splitter.SplitByNothing(), {"Column1"}),
        firstRow = tableOfPages{0}?
    in
        if (firstRow = null) then
            Table.FromRows({})
        else
            Value.ReplaceType(
                Table.ExpandTableColumn(tableOfPages, "Column1", Table.ColumnNames(firstRow[Column1])),
                Value.Type(firstRow[Column1])
            );


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
shared GithubSample.PagedTable = Value.ReplaceType(Github.PagedTable, type function (url as Uri.Type) as any);

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

Github.Contents = (url as text) =>
    let
        content = Web.Contents(url),
        link = GetNextLink(Value.Metadata(content)[Headers][#"Link"]?),
        json = Json.Document(content)
    in
        json meta [Next=link];

Github.PagedTable = (url as text) => Table.GenerateByPage((previous) =>
    let
        next = if previous = null then null else Value.Metadata(previous)[Next],
        current = if previous <> null and next = null then null else Github.Contents(if next = null then url else next),
        link = if current = null then null else Value.Metadata(current)[Next],
        table = if current = null then null else Table.FromList(current, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
    in
        table meta [Next=link]);

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

GetNextLink = (link) =>
    let
        links = Text.Split(link, ","),
        splitLinks = List.Transform(links, each Text.Split(Text.Trim(_), ";")),
        next = List.Select(splitLinks, each Text.Trim(_{1}) = "rel=""next"""),
        first = List.First(next),
        removedBrackets = Text.Range(first{0}, 1, Text.Length(first{0}) - 2)
    in
        try removedBrackets otherwise null;
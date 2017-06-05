section MyGraph;

//
// OAuth configuration settings
//
client_id = Text.FromBinary(Extension.Contents("client_id")); // TODO: set AAD client ID value in the client_id file
redirect_uri = "https://preview.powerbi.com/views/oauthredirect.html";
token_uri = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
authorize_uri = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize";
logout_uri = "https://login.microsoftonline.com/logout.srf";

windowWidth = 720;
windowHeight = 1024;

// See https://developer.microsoft.com/en-us/graph/docs/authorization/permission_scopes 
scope_prefix = "https://graph.microsoft.com/";
scopes = {
    "User.ReadWrite",
    "Contacts.Read",
    "User.ReadBasic.All",
    "Calendars.ReadWrite",
    "Mail.ReadWrite",
    "Mail.Send",
    "Contacts.ReadWrite",
    "Files.ReadWrite",
    "Tasks.ReadWrite",
    "People.Read",
    "Notes.ReadWrite.All",
    "Sites.Read.All"
};

//
// Exported function(s)
//
[DataSource.Kind="MyGraph", Publish="MyGraph.UI"]
shared MyGraph.Feed = () =>
    let
        source = OData.Feed("https://graph.microsoft.com/v1.0/me/", null, [ ODataVersion = 4, MoreColumns = true ])
    in
        source;

//
// Data Source definition
//
MyGraph = [
    Authentication = [
        OAuth = [
            StartLogin=StartLogin,
            FinishLogin=FinishLogin,
            Refresh=Refresh,
            Logout=Logout
        ]
    ],
    Label = "My Graph Connector"
];

//
// UI Export definition
//
MyGraph.UI = [
    Beta = true,
    ButtonText = { "MyGraph.Feed", "Connect to Graph" },
    SourceImage = MyGraph.Icons,
    SourceTypeImage = MyGraph.Icons
];

MyGraph.Icons = [
    Icon16 = { Extension.Contents("MyGraph16.png"), Extension.Contents("MyGraph20.png"), Extension.Contents("MyGraph24.png"), Extension.Contents("MyGraph32.png") },
    Icon32 = { Extension.Contents("MyGraph32.png"), Extension.Contents("MyGraph40.png"), Extension.Contents("MyGraph48.png"), Extension.Contents("MyGraph64.png") }
];

//
// OAuth implementation
//
// See the following links for more details on AAD/Graph OAuth:
// * https://docs.microsoft.com/en-us/azure/active-directory/active-directory-protocols-oauth-code 
// * https://graph.microsoft.io/en-us/docs/authorization/app_authorization
//
StartLogin = (resourceUrl, state, display) =>
    let
        authorizeUrl = authorize_uri & "?" & Uri.BuildQueryString([
            client_id = client_id,  
            redirect_uri = redirect_uri,
            state = state,
            scope = GetScopeString(scopes, scope_prefix),
            response_type = "code",
            response_mode = "query",
            login = "login"    
        ])
    in
        [
            LoginUri = authorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        parts = Uri.Parts(callbackUri)[Query],
        result = if (Record.HasFields(parts, {"error", "error_description"})) then 
                    error Error.Record(parts[error], parts[error_description], parts)
                 else
                    TokenMethod("authorization_code", parts[code])
    in
        result;

Refresh = (resourceUrl, refresh_token) => TokenMethod("refresh_token", refresh_token);

Logout = (token) => logout_uri;

TokenMethod = (grantType, code) =>
    let
        tokenResponse = Web.Contents(token_uri, [
            Content = Text.ToBinary(Uri.BuildQueryString([
                client_id = client_id,
                code = code,
                scope = GetScopeString(scopes, scope_prefix),
                grant_type = grantType,
                redirect_uri = redirect_uri])),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ],
            ManualStatusHandling = {400} 
        ]),
        body = Json.Document(tokenResponse),
        result = if (Record.HasFields(body, {"error", "error_description"})) then 
                    error Error.Record(body[error], body[error_description], body)
                 else
                    body
    in
        result;

//
// Helper Functions
//
Value.IfNull = (a, b) => if a <> null then a else b;

GetScopeString = (scopes as list, optional scopePrefix as text) as text =>
    let
        prefix = Value.IfNull(scopePrefix, ""),
        addPrefix = List.Transform(scopes, each prefix & _),
        asText = Text.Combine(addPrefix, " ")
    in
        asText;


// This file contains your Data Connector logic
section DataWorldSwagger;

// TODO: add your client id and secret to the embedded files
client_id = Text.FromBinary(Extension.Contents("client_id"));
client_secret = Text.FromBinary(Extension.Contents("client_secret"));

redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html";
windowWidth = 800;
windowHeight = 800;

BaseUrl = "https://api.data.world/v0";
OAuthBaseUrl = "https://data.world/oauth";

[DataSource.Kind="DataWorldSwagger", Publish="DataWorldSwagger.Publish"]
shared DataWorldSwagger.Contents = () =>
    let
        credential = Extension.CurrentCredential(),
        token = if (credential[AuthenticationKind] = "Key") then credential[Key] else credential[access_token],        
        headers = [ Authorization = "Bearer " & token ],
        navTable = OpenApi.Document(Web.Contents("https://api.data.world/v0/swagger.json"), [ Headers = headers, ManualCredentials = true ])
    in
        navTable;

// Data Source Kind description
DataWorldSwagger = [
    // enable both OAuth and Key based auth
    Authentication = [
        OAuth = [
            StartLogin = StartLogin,
            FinishLogin = FinishLogin,
            Refresh=Refresh
        ],
        Key = [
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
DataWorldSwagger.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://data.world/"
];

//
// OAuth2 flow definition
//

StartLogin = (resourceUrl, state, display) =>
    let
        AuthorizeUrl = OAuthBaseUrl & "/authorize?" & Uri.BuildQueryString([
            client_id = client_id,
            response_type = "code",
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
        TokenMethod(Parts[code], "authorization_code");

TokenMethod = (code, grant_type) =>
    let
        Response = Web.Contents(OAuthBaseUrl & "/access_token", [
            Content = Text.ToBinary(Uri.BuildQueryString([
                client_id = client_id,
                client_secret = client_secret,
                code = code,
                grant_type = grant_type,
                redirect_uri = redirect_uri])),
            Headers=[#"Content-type" = "application/x-www-form-urlencoded",#"Accept" = "application/json"]]),
        Parts = Json.Document(Response)
    in
        Parts;

Refresh = (resourceUrl, refresh_token) => TokenMethod(refresh_token, "refresh_token");

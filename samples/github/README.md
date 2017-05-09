# Github Connector Sample
The Github M extension shows how to add support for an OAuth 2.0 protocol authentication flow. You can learn more about the specifics for Github's authentication flow on the [Github Developer site](https://developer.github.com/guides/basics-of-authentication/).

Before you get started creating an M extension, you need to register a new app on Github, and replace the `client_id` and `client_secret` files with the appropriate values for you app.

**Note about compatibility issues in Visual Studio:** _The Power Query SDK uses an Internet Explorer based control to popup OAuth dialogs. Github has deprecated its support for the version of IE used by this control, which will prevent you from completing the permission grant for you app if run from within Visual Studio. An alternative is to load the extension with Power BI  Desktop and complete the first OAuth flow there. After your application has been granted access to your account, subsequent logins will work fine from Visual Studio._

## OAuth and Power BI
OAuth is a form of credentials delegation. By logging in to Github and authorizing the "application" you create for Github, the user is allowing your "application" to login on their behalf to retrieve data into Power BI.
The "application" must be granted rights to retrieve data (get an access_token) and to refresh the data on a schedule (get and use a refresh_token).
Your "application" in this context is your Data Connector used to run queries within Power BI.
Power BI stores and manages the access_token and refresh_token on your behalf.

**Note:** To allow Power BI to obtain and use the access_token, you must specify the redirect url as: https://oauth.powerbi.com/views/oauthredirect.html

When you specify this URL and Github successfully authenticates and grants permissions, Github will redirect to PowerBI's oauthredirect endpoint so that Power BI can retrieve the access_token and refresh_token. 

## How to register a Github app
Your Power BI extension needs to login to Github. To enable this, you register a new OAuth application with Github at https://Github.com/settings/applications/new.
1. `Application name`: Enter a name for the application for your M extension.  
2. `Authorization callback URL`: Enter https://oauth.powerbi.com/views/oauthredirect.html.  
3. `Scope`: In Github, set scope to `user, repo`.  
**Note:** A registered OAuth application is assigned a unique Client ID and Client Secret. The Client Secret should not be shared. You get the Client ID and Client Secret from the Github application page.
Update the files in your Data Connector project with the Client ID (`client_id` file) and Client Secret (`client_secret` file).

## How to implement Github OAuth
This sample will walk you through the following steps:

1. Create a Data Source Kind definition that declares it supports OAuth
2. Provide details so the M engine can start the OAuth flow (`StartLogin`)
3. Convert the code received from Github into an access_token (`FinishLogin` and `TokenMethod`)
4. Define functions that access the Github API (`GithubSample.Contents`)

### Step 1 – Create a Data Source definition
A Data Connector starts with a [record](https://msdn.microsoft.com/en-us/library/mt299038.aspx#record) that describes the extension, including its unique name (which is the name of the record), supported authentication type(s), and a friendly display name (label) for the data source.
When supporting OAuth, the definition contains the functions that implement the OAuth contract - in this case, `StartLogin` and `FinishLogin`.

```
//
// Data Source definition
//
GithubSample = [
    Authentication = [
        OAuth = [
            StartLogin = StartLogin,
            FinishLogin = FinishLogin
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];
```

### Step 2 - Provide details so the M engine can start the OAuth flow
The Github OAuth flow starts when you direct users to the `https://Github.com/login/oauth/authorize` page.
For the user to login, you need to specify a number of query parameters:

|Name		|Type   |Description|
|:----------|:------|:----------|
|client_id|string|**Required**. The client ID you received from Github when you registered.|
|redirect_uri|string|The URL in your app where users will be sent after authorization. See details below about redirect urls. For M extensions, the `redirect_uri` must be "https://oauth.powerbi.com/views/oauthredirect.html". |
|scope|string|A comma separated list of scopes. If not provided, scope defaults to an empty list of scopes for users that don't have a valid token for the app. For users who do already have a valid token for the app, the user won't be shown the OAuth authorization page with the list of scopes. Instead, this step of the flow will automatically complete with the same scopes that were used last time the user completed the flow.| 
|state|string|An unguessable random string. It is used to protect against cross-site request forgery attacks.| 

This code snippet describes how to implement a `StartLogin` function to start the login flow.
A `StartLogin` function takes a `resourceUrl`, `state`, and `display` value.
In the function, create an AuthorizeUrl that concatenates the Github authorize url with the following parameters:

* `client_id`: You get the client id after you register your extension with Github from the Github application page.
* `scope`: Set scope to "`user, repo`". This sets the authorization scope (i.e. what your app wants to access) for the user.
* `state`: An internal value that the M engine passes in.
* `redirect_uri`: Set to https://preview.powerbi.com/views/oauthredirect.html

```
StartLogin = (resourceUrl, state, display) =>
        let
            AuthorizeUrl = "https://Github.com/login/oauth/authorize?" & Uri.BuildQueryString([
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
```

If this is the first time the user is logging in with your app (identified by its `client_id` value), they will see a page that asks them to grant access to your app. Subsequent login attempts will simply ask for their credentials.

### Step 3 - Convert the code received from Github into an access_token
If the user completes the authentication flow, Github redirects back to the Power BI redirect URL with a temporary code in a `code` parameter, as well as the state you provided in the previous step in a `state` parameter. Your `FinishLogin` function will extract the code from the `callbackUri` parameter, and then exchange it for an access token (using the `TokenMethod` function).

```
FinishLogin = (context, callbackUri, state) =>
    let
        Parts = Uri.Parts(callbackUri)[Query]
    in
        TokenMethod(Parts[code]);
```

To get a Github access token, you pass the temporary code from the Github Authorize Response. In the `TokenMethod` function you formulate a POST request to Github's access_token endpoint (`https://github.com/login/oauth/access_token`).
The following parameters are required for the Github endpoint:

|Name         |Type  |Description|
|:------------|:-----|:----------|
|client_id    |string|**Required**. The client ID you received from Github when you registered|
|client_secret|string|**Required**. The client secret you received from Github when you registered|
|code         |string|**Required**. The code you received in `FinishLogin`|
|redirect_uri |string|The URL in your app where users will be sent after authorization. See details below about redirect urls.|

Here are the details used parameters for the [Web.Contents](https://msdn.microsoft.com/en-us/library/mt260892.aspx) call.

|Argument|Description|Value|
|:-------|:----------|:----|
|url     |The URL for the Web site.                             |https://Github.com/login/oauth/access_token |
|options |A record to control the behavior of this function.    |Not used in this case                       |
|Query   |Programmatically add query parameters to the URL.     |<code>Content = Text.ToBinary(<br>Uri.BuildQueryString(<br>[<br>client_id = client_id,<br>client_secret = client_secret,<br>code = code,<br>redirect_uri = redirect_uri<br>]<br>))</code><br>Where<br><ul><li>`client_id`: Client ID from Github application page.<li>`client_secret`: Client secret from Github application page.<li>`code`: Code in Github authorization response.<li>`redirect_uri`: The URL in your app where users will be sent after authorization.|
|Headers |A record with additional headers for the HTTP request.|<code>Headers= [<br>#"Content-type" = "application/x-www-form-urlencoded",<br>#"Accept" = "application/json"<br>]|

This code snippet describes how to implement a `TokenMethod` function to exchange an auth code for an access token.
```
TokenMethod = (code) =>
    let
        Response = Web.Contents("https://Github.com/login/oauth/access_token", [
            Content = Text.ToBinary(Uri.BuildQueryString([
                client_id = client_id,
                client_secret = client_secret,
                code = code,
                redirect_uri = redirect_uri])),
            Headers=[#"Content-type" = "application/x-www-form-urlencoded",#"Accept" = "application/json"]]),
        Parts = Json.Document(Response)
    in
        Parts;
```

The JSON response from the service will contain an access_token field. `TokenMethod` method converts the JSON response into an M record using [Json.Document](https://msdn.microsoft.com/en-us/library/mt260861.aspx), and returns it to the engine.

Sample response:
```json
{
    "access_token":"e72e16c7e42f292c6912e7710c838347ae178b4a",
    "scope":"user,repo",
    "token_type":"bearer"
}
```

### Step 4 - Define functions that access the Github API
The following code snippet exports two functions (`GithubSample.Contents` and `GithubSample.PagedTable`)
by marking them as `shared`, and associates them with the `GithubSample` Data Source Kind. 

```
[DataSource.Kind="GithubSample", Publish="GithubSample.UI"]
shared GithubSample.Contents = Value.ReplaceType(Github.Contents, type function (url as Uri.Type) as any);

[DataSource.Kind="GithubSample"]
shared GithubSample.PagedTable = Value.ReplaceType(Github.PagedTable, type function (url as Uri.Type) as any);
```

The `GithubSample.Contents` function is also published to the UI (allowing it to appear in the Get Data dialog). The [Value.ReplaceType](https://msdn.microsoft.com/en-us/library/mt260838.aspx)
function is used to set the function parameter to the `Url.Type` ascribed type.

By associating these functions with the `GithubSample` data source kind, they will automatically use the credentials that the user provided. Any M library functions that have been enabled for extensibility (such as Web.Contents) will automatically inherit these credentials as well.

For more details on how credential and authentication works, please see the [Data Connector Technical Reference](../../docs/m-extensions.md).


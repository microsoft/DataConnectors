# TODO
- [ ] Update code samples to match section document format
- [ ] Explain client_id and client_secret loading from resource
- [ ] Update introduction wording
- [ ] Finish explaining contents and pagedtable functions

# Github Connector Sample
The Github "M" Extension uses the OAuth2 authentication flow. Github APIs use the OAuth 2.0 protocol for authentication and authorization. You can learn more about Github OAuth on the Github Developer site.
Before you get started creating an "M" extension, you need to register the extension with Github. 

## OAuth and Power BI
OAuth is a form of credentials delegation. By logging in to Github and authorizing the "application" you create for Github, the user is allowing your "application" to login on their behalf to retrieve data into Power BI.  The application must be granted rights to retrieve data (get an access_token) and to refresh the data on a schedule (get and use a refresh_token).   Your "application" in this context is your content pack queries running within the Power BI service.  Power BI stores and manages the access_token and refresh_token on your content pack’s behalf.  To allow Power BI to obtain and use the access_token, you must specify the redirect url as:
https://oauth.powerbi.com/views/oauthredirect.html

When you specify this URL and Github successfully authenticates and grants permissions, Github will redirect to PowerBI’s oauthredirect endpoint so that Power BI can retrieve the access_token and refresh_token. 

## How to register a Github app
Your Power BI "M" extension needs to login to Github.  To enable this, you register a new OAuth application with Github at https://Github.com/settings/applications/new.
1. `Application name`: Enter a name for the application for your "M" extension.  
2. `Authorization callback URL`: Enter https://oauth.powerbi.com/views/oauthredirect.html.  
3. `Scope`: In Github, set scope to `user, repo`.  
**Note:** A registered OAuth application is assigned a unique Client ID and Client Secret. The Client Secret should not be shared. You get the Client ID and Client Secret from the Github application page.
Update the lines in your "M" extension with the Client ID and Client Secret:
```
    client_id = "{client id from Github app registration}",
    client_secret = "{client id from Github app registration}",
```

## How to implement Github OAuth
To create an "M" extension that implements Github OAuth:
1. Define an Extension Resource  
2. Redirect users to request Github access  
3. Github redirects back to Power BI to access token  
4. Use the access token to access the API  
5. Implement a login callback and generate a Power BI page  

### Step 1 – Define an Extension Resource
A Power BI "M" extension starts with a metadata record that describes the extension including the type, resource path, an identifier to the Github OAuth start and finish functions, and  an identifier to the Github user repo contents.
An "M" record or metadata is a set of fields. A field is a name/value pair where the name is a text value that is unique within the field’s record. The literal syntax for record values allows the names to be written without quotes, a form also referred to as identifiers.
```
Resource = [
    Description = "Github",
    Type="Singleton",
    MakeResourcePath = () => "Github",
    ParseResourcePath = (resource) => { },
    TestConnection = (resource) => { "Github.Contents", "https://api.Github.com/user" },
    Authentication=[OAuth=[StartLogin=StartLogin, FinishLogin=FinishLogin]],
    Exports = [
        Github.Contents = Github.Contents,
        Github.PagedTable = Github.PagedTable
    ]
],
Extension = Extension.Module("Github", { Resource })
```
NOTE: The file name for your "M" extension must match exactly the name of the Module you specify.
If you provide:
Extension = Extension.Module("Github", { Resource })
Then the file name must be:
Github.m

### Step 2 - Redirect users to request Github access
To redirect users to request Github access, create a StartLogin function and set AuthorizeUrl.
`GET https://Github.com/login/oauth/authorize`

To request Github access you need to pass these parameters:

|Name		|Type   |Description|
|:----------|:------|:----------|
|client_id|string|Required. The client ID you received from Github when you registered.|
|redirect_uri|string|The URL in your app where users will be sent after authorization. See details below about redirect urls. **NOTE:** For "M" extensions, the redirect_uri must be "https://oauth.powerbi.com/views/oauthredirect.html". |
|scope|string|A comma separated list of scopes. If not provided, scope defaults to an empty list of scopes for users that don’t have a valid token for the app. For users who do already have a valid token for the app, the user won’t be shown the OAuth authorization page with the list of scopes. Instead, this step of the flow will automatically complete with the same scopes that were used last time the user completed the flow.| 
|state|string|An unguessable random string. It is used to protect against cross-site request forgery attacks.| 

This code snippet describes how to implement a `StartLogin` function to redirect users to request Github access. For the complete code listing, see Complete Github "M" Extension.
A `StartLogin` function takes a resourceUrl, state, and display.
In the function, create an AuthorizeUrl that concatenates the Github authorize url with

* `client_id`: You get the client id after you register your extension with Github from the Github application page.
* `scope`: Set scope to `"user, repo"`. This sets the authorization scope to users and repos for a user.
* `state`: An internal value that the M engine passes.
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
            ],
```
### Step 3 - Github redirects back to your site with an authorization code to access a token
If the user accepts your request, Github redirects back to the Power BI redirect URL with a temporary code in a code parameter as well as the state you provided in the previous step in a state parameter. The Power BI redirect URL is https://oauth.powerbi.com/views/oauthredirect.html. If the states don’t match, the request has been created by a third party and the process should be aborted. You exchange the code for an access token.
`POST https://Github.com/login/oauth/access_token`

#### Parameters
|Name|Type|Description|
|:----|:----|:----------|
|client_id|string|Required. The client ID you received from Github when you registered.|
|client_secret|string|Required. The client secret you received from Github when you registered.|
|code|string|Required. The code you received as a response to Step 1.|
|redirect_uri|string|The URL in your app where users will be sent after authorization. See details below about redirect urls.|

To get a Github access token, you pass the temporary code from the Github Authorize Response. See Step 2 - Redirect users to request Github access. In the TokenMethod function, return the token contents as a binary value using `Web.Contents`.

#### Parameters for Web.Contents
|Argument|Description|Value|
|:-------|:----------|:----|
|url|The URL for the Web site.|https://Github.com/login/oauth/access_token |
|Options Record|A record to control the behavior of this function.|NA|
|Query|Programmatically add query parameters to the URL.|<code>Content = Text.ToBinary(<br>Uri.BuildQueryString(<br>[<br>client_id = client_id,<br>client_secret = client_secret,<br>code = code,<br>redirect_uri = redirect_uri<br>]<br>))</code><br>Where<br><ul><li>`client_id`: Client ID from Github application page.<li>`client_secret`: Client secret from Github application page.<li>`code`: Code in Github authorization response.<li>`redirect_uri`: The URL in your app where users will be sent after authorization.|
|Headers|A record for additional headers to an HTTP request.|<code>Headers= [<br>#"Content-type" = "application/x-www-form-urlencoded",<br>#"Accept" = "application/json"<br>]|

This code snippet describes how to implement a TokenMethod function to redirect users to request Github access. For the complete code listing, see Complete Github "M" Extension.
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
        Parts,
```
### Step 4 - Use the access token to access the API
The access token allows you to make requests to the Github API on a behalf of a user.
`GET https://api.Github.com/user?access_token=... `

When you use the Accept header as part of access_token POST, the response takes the form:
```
Accept: application/json
{"access_token":"e72e16c7e42f292c6912e7710c838347ae178b4a", "scope":"repo,gist", "token_type":"bearer"}
```

You can pass the token in the query params or in the Authorization header
`Authorization: token OAUTH-TOKEN`

Code:
```
TestConnection = (resource) => { "Github.Contents", "https://api.Github.com/user" },
Authentication=[OAuth=[StartLogin=StartLogin, FinishLogin=FinishLogin]],
Exports = [
    Github.Contents = Github.Contents,
    Github.PagedTable = Github.PagedTable
]
```

### Step 5 - Login callback
Implement a FinishLogin function as a login callback. 
```
FinishLogin = (context, callbackUri, state) =>
    let
        Parts = Uri.Parts(callbackUri)[Query]
    in
        TokenMethod(Parts[code]),
```


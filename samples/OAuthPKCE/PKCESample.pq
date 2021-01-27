// This is not a complete connector sample, but demonstrates a PKCE based OAuth flow
[Version="1.0.0"]
section PKCESample;

// Native client flow (PKCE)
// see https://tools.ietf.org/html/rfc7636
// see https://oauth.net/2/pkce/

OAuthBaseUrl = "https://your-service-url/oauth";

StartLogin = (resourceUrl, state, display) =>
    let
        // We'll generate our code verifier using Guids
        codeVerifier = Text.NewGuid() & Text.NewGuid(),
        AuthorizeUrl = OAuthBaseUrl & "/authorize?" & Uri.BuildQueryString([
            client_id = client_id,
            response_type = "code",
            code_challenge_method = "plain",
            code_challenge = codeVerifier,
            state = state,
            redirect_uri = redirect_uri])
    in
        [
            LoginUri = AuthorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = windowHeight,
            WindowWidth = windowWidth,
            // Need to roundtrip this value to FinishLogin
            Context = codeVerifier
        ];

// The code verifier will be passed in through the context parameter.
FinishLogin = (context, callbackUri, state) =>
    let
        Parts = Uri.Parts(callbackUri)[Query]
    in
        TokenMethod(Parts[code], "authorization_code", context);

// Verifier is optional to support both the original FinishLogin call
// (which has a verifier) and the Refresh call (which does not).
TokenMethod = (code, grant_type, optional verifier) =>
    let
        codeVerifier = if (verifier <> null) then [code_verifier = verifier] else [],
        codeParameter = if (grant_type = "authorization_code") then [ code = code ] else [ refresh_token = code ],
        query = codeVerifier & codeParameter & [
            client_id = client_id,
            // Native client flows should not require a client_secret when using PKCE, but some still do.
            // client_secret = client_secret,
            grant_type = grant_type,
            redirect_uri = redirect_uri
        ],
 
        // Set this if your API returns a non-2xx status for login failures
        // ManualHandlingStatusCodes = {400, 403}
        ManualHandlingStatusCodes= {},
        
        Response = Web.Contents(OAuthBaseUrl & "/access_token", [
            Content = Text.ToBinary(Uri.BuildQueryString(query)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ],
            ManualStatusHandling = ManualHandlingStatusCodes
        ]),
        Parts = Json.Document(Response)
    in
        // check for error in response
        if (Parts[error]? <> null) then 
            error Error.Record(Parts[error], Parts[message]?)
        else
            Parts;
 
Refresh = (resourceUrl, refresh_token) => TokenMethod(refresh_token, "refresh_token");

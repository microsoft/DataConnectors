// This is not a complete connector sample, but demonstrates a PKCE based OAuth flow
[Version = "2.0.0"]
section PKCESample;

// Native client flow (PKCE)
// see https://tools.ietf.org/html/rfc7636
// see https://oauth.net/2/pkce/
OAuthBaseUrl = "https://your-service-url/oauth/";
AuthorizeUrl = Uri.Combine(OAuthBaseUrl, "authorize");
TokenUrl = Uri.Combine(OAuthBaseUrl, "token");

client_id = "your-client-id";

// The sample provides two code_challenge_method examples: "plain" and "S256".
code_challenge_method = "S256";

// Other OAuth settings
windowWidth = 720;
windowHeight = 1024;

// This is the expected Redirect URI for OAuth flows to work in the Power BI service.
redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html";

StartLogin = (resourceUrl, state, display) =>
    let
        // We'll generate our code verifier using Guids
        plainTextCodeVerifier = Text.NewGuid() & Text.NewGuid(),
        codeVerifier =
            if (code_challenge_method = "plain") then
                plainTextCodeVerifier
            else if (code_challenge_method = "S256") then
                Base64Url.Encode(Crypto.CreateHash(CryptoAlgorithm.SHA256, Text.ToBinary(plainTextCodeVerifier)))
            else
                error "Unexpected code_challenge_method",

        AuthorizeUrl = AuthorizeUrl
            & "?"
            & Uri.BuildQueryString(
                [
                    client_id = client_id,
                    response_type = "code",
                    code_challenge_method = code_challenge_method,
                    code_challenge = codeVerifier,
                    state = state,
                    redirect_uri = redirect_uri
                ]
            )
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
        codeParameter = if (grant_type = "authorization_code") then [code = code] else [refresh_token = code],
        query = codeVerifier
            & codeParameter
            & [
                client_id = client_id,
                // Native client flows should not require a client_secret when using PKCE, but some still do.
                // client_secret = client_secret,
                grant_type = grant_type,
                redirect_uri = redirect_uri
            ],
        // Set this if your API returns a non-2xx status for login failures
        // ManualHandlingStatusCodes = {400, 403}
        ManualHandlingStatusCodes = {},
        Response = Web.Contents(
            TokenUrl,
            [
                Content = Text.ToBinary(Uri.BuildQueryString(query)),
                Headers = [
                    #"Content-type" = "application/x-www-form-urlencoded",
                    #"Accept" = "application/json"
                ],
                ManualStatusHandling = ManualHandlingStatusCodes
            ]
        ),
        Parts = Json.Document(Response)
    in
        // check for error in response
        if (Parts[error]? <> null) then
            error Error.Record(Parts[error], Parts[message]?)
        else
            Parts;

Refresh = (resourceUrl, refresh_token) => TokenMethod(refresh_token, "refresh_token");

Base64Url.Encode = (s) => Text.Replace(Text.Replace(Text.BeforeDelimiter(Binary.ToText(s,0),"="),"+","-"),"/","_");

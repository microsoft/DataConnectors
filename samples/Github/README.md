# Github Connector Sample
The Github M extension shows how to add support for an OAuth 2.0 protocol authentication flow. You can learn more about the specifics for Github's authentication flow on the [Github Developer site](https://developer.github.com/guides/basics-of-authentication/).

Before you get started creating an M extension, you need to register a new app on Github, and replace the `client_id` and `client_secret` files with the appropriate values for you app.

**Note about compatibility issues in Visual Studio:** _The Power Query SDK uses an Internet Explorer based control to popup OAuth dialogs. Github has deprecated its support for the version of IE used by this control, which will prevent you from completing the permission grant for you app if run from within Visual Studio. An alternative is to load the extension with Power BI  Desktop and complete the first OAuth flow there. After your application has been granted access to your account, subsequent logins will work fine from Visual Studio._

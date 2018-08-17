# MyGraph Connector Sample
In this sample we will create a basic data source connector for [Microsoft Graph](https://graph.microsoft.io/en-us/). It is written as a walk-through that you can follow step by step.

To access Graph, you will first need to register your own Azure Active Directory client application. If you do not have an application ID already, you can create one through the [Getting Started with Microsoft Graph](https://graph.microsoft.io/en-us/getting-started) site.
Click the "Universal Windows" option, and then the "Let's go" button. Follow the steps and receive an App ID. As described in the tutorial, use `https://oauth.powerbi.com/views/oauthredirect.html` as your redirect URI when registering your app. 
Client ID value, use it to replace the existing value in the `client_id` file in the code sample.

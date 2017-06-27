//
// Use this file to write test queries to run from Visual Studio.
// Documentation: https://github.com/Microsoft/DataConnectors/blob/master/docs/m-extensions.md#query-file
//
let
    source = GithubSample.Contents("https://api.github.com/")
in
    source

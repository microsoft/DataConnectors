// Use this file to write queries to test your data connector.
// Pressing Evaluate (or Ctrl+E) in VS Code will execute this query
// against the extension defined in .vscode/settings.json.
let
    Source = DuckDb.Contents("localhost:31337", "Disabled")
in
    Source

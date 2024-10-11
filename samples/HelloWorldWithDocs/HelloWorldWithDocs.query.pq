let
    Source = HelloWorldWithDocs.Contents("Hello world", 2, [ ]),
    WithOptions = HelloWorldWithDocs.Contents("With Options", 1, [ enumField = "option2"])
in
    // Source
    WithOptions

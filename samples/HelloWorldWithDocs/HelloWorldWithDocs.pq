section HelloWorldWithDocs;

[DataSource.Kind = "HelloWorldWithDocs", Publish = "HelloWorldWithDocs.Publish"]
shared HelloWorldWithDocs.Contents = Value.ReplaceType(HelloWorldImpl, HelloWorldType);

HelloWorldType = type function (
    message as (
        type text meta [
            Documentation.FieldCaption = "Message",
            Documentation.FieldDescription = "Text to display",
            Documentation.SampleValues = {"Hello world", "Hola mundo"}
        ]
    ),
    optional count as (
        type number meta [
            Documentation.FieldCaption = "Count",
            Documentation.FieldDescription = "Number of times to repeat the message",
            Documentation.AllowedValues = {1, 2, 3}
        ]
    )
) as table meta [
    Documentation.Name = "Hello - Name",
    Documentation.LongDescription = "Hello - Long Description",
    Documentation.Examples = {
        [
            Description = "Returns a table with 'Hello world' repeated 2 times",
            Code = "HelloWorldWithDocs.Contents(""Hello world"", 2)",
            Result = "#table({""Column1""}, {{""Hello world""}, {""Hello world""}})"
        ],
        [
            Description = "Another example, new message, new count!",
            Code = "HelloWorldWithDocs.Contents(""Goodbye"", 1)",
            Result = "#table({""Column1""}, {{""Goodbye""}})"
        ]
    }
];

HelloWorldImpl = (message as text, optional count as number) as table =>
    let
        _count = if (count <> null) then count else 5,
        listOfMessages = List.Repeat({message}, _count),
        table = Table.FromList(listOfMessages, Splitter.SplitByNothing())
    in
        table;

// Data Source Kind description
HelloWorldWithDocs = [
    Authentication = [
        Anonymous = []
    ]
    // ,
    // Label = "Hello World With Docs"
];

// Data Source UI publishing description
HelloWorldWithDocs.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {"Hello World With Docs", "Provides an example of how to provide function documentation"}
];

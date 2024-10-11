section HelloWorldWithDocs;

[DataSource.Kind = "HelloWorldWithDocs", Publish = "HelloWorldWithDocs.Publish"]
shared HelloWorldWithDocs.Contents = Value.ReplaceType(HelloWorldImpl, HelloWorldType);

// The function type should have the same parameters (names, primitive data types, required vs. option)
// and names as the implementation it will be used for.
HelloWorldType = type function (
    message as (
        type text meta [
            // FieldCaption becomes the parameter label.
            Documentation.FieldCaption = "Message",
            // FieldDescription becomes the parameter tooltip.
            Documentation.FieldDescription = "Text to display",
            // SampleValues is an M list value (i.e. surrounded with curly brackets). 
            // The sample values are displayed as watermark text in the input field.
            // The displayed value might be truncated if the text is too long for the input field.
            // A single sample value should still be a list - for example: {"My value"}, not "My value".
            Documentation.SampleValues = {"Hello world", "Hola mundo"}
        ]
    ),
    optional count as (
        type number meta [
            Documentation.FieldCaption = "Count",
            Documentation.FieldDescription = "Number of times to repeat the message",
            // Documentation.AllowedValues is an M list value.
            // The allowed values are typically displayed as a dropdown list in the input field.
            // NOTE: Allowed values will be included in the generated user query and should NOT
            // include localized strings.
            Documentation.AllowedValues = {1, 2, 3}
        ]
    )
) as table meta [
    Documentation.Name = "Hello - Name",
    Documentation.LongDescription = "Hello - Long Description",
    // Documentation.Examples is an M list value.
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
];

// Data Source UI publishing description
HelloWorldWithDocs.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {"Hello World With Docs", "Provides an example of how to provide function documentation"}
];

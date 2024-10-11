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
            // include localized strings. Please see the "enumField" example in the options record
            // for an example of how to provide localized captions.
            Documentation.AllowedValues = {1, 2, 3}
        ]
    ),
    // A data source "options" record is a common way to pass in advanced settings and allows the connector
    // to add new settings without impacting backwards compatibility. The options record should be the final
    // parameter of the function, marked as option, be named "options", and have a record type.
    optional options as (
        // The code below defines a new record type. Each field in the record type becomes an input field
        // in the UI. Not all options record fields need to be documented, but anything included here should be
        // considered part of the function contract (i.e. future changes should not impact backwards compatibility).
        // For more information on defining record types, see: https://learn.microsoft.com/powerquery-m/m-spec-types#record-types
        type nullable [
            // Options record fields support the same Documentation.* meta fields as function parameters.
            // All fields should be optional.
            optional startDate = (type date meta [
                Documentation.FieldCaption = "Start Date",
                Documentation.FieldDescription = "This is a start date parameter"
            ]),
            optional flag = (type logical meta [
                Documentation.FieldCaption = "Logical flag",
                Documentation.FieldDescription = "A logical/boolean parameter"
            ]),
            optional enumField = (type text meta [
                Documentation.FieldCaption = "Enum field",
                Documentation.FieldDescription = "This field is displayed as a drop down list",
                // In this advanced example, each of the AllowedValues is a text value with
                // additional metadata to set the caption. This allows for localized captions,
                // as the generated M query will contain the text value. Note that in this case
                // we use "Documentation.Caption" rather than "Documentation.FieldCaption".
                Documentation.AllowedValues = {
                    "option1" meta [ Documentation.Caption = "First option" ],
                    "option2" meta [ Documentation.Caption = "Second option" ]
                }
            ])
        ] meta [
            // Connectors don't need to provide a FieldCaption for the options record.
            // The default label will be a localized equivalent of "Advanced options".
            // Documentation.FieldCaption = "Advanced options",
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
        ],
        [
            Description = "An example with options",
            Code = "HelloWorldWithDocs.Contents(""With Options"", 1, [ enumField = ""option2""])",
            Result = "#table({""Column1"", ""AllOptions"", ""EnumField""}, {{""Goodbye"", ""[Record]"", ""option2""}})"
        ]
    }
];

// Depending on how the M query was generated, the options record might be a null value, an empty record ( [] ),
// or a record with fields that have null values ( [ startDate = null, flag = null, enumField = null ] ).
// The connector should handle all of these cases.
HelloWorldImpl = (message as text, optional count as number, optional options as record) as table =>
    let
        // Set defaults for optional parameters to avoid having to check for null values.
        _count = count ?? 5,
        _options = options ?? [],
        // Check for a specific option. The ? operator after _options[enumField] returns null if the field is not found (rather than an error).
        enumFieldValue = _options[enumField]? ?? "N/A",
        listOfMessages = List.Repeat({message}, _count),
        asTable = Table.FromList(listOfMessages, Splitter.SplitByNothing()),
        // If the original query had non-null options, add them to the result.
        finalTable =
            if (options <> null) then
                let
                    withOptions = Table.AddColumn(asTable, "AllOptions", each _options, type nullable record),
                    withEnumField = Table.AddColumn(withOptions, "EnumField", each enumFieldValue, type text)
                in
                    withEnumField
            else
                asTable
    in
        finalTable;

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

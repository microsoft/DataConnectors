﻿section TripPin;

[DataSource.Kind = "TripPin", Publish = "TripPin.Publish"]
shared TripPin.Feed = Value.ReplaceType(TripPinImpl, type function (url as Uri.Type) as any);

DefaultRequestHeaders = [
    // column name and values only
    #"Accept" = "application/json;odata.metadata=minimal",
    // we only support v4
    #"OData-MaxVersion" = "4.0"
];

TripPinImpl = (url as text) =>
    let
        source = Web.Contents(url, [Headers = DefaultRequestHeaders]), json = Json.Document(source)
    in
        json;

// Data Source Kind description
TripPin = [
    Authentication = [
        Anonymous = []
    ],
    Label = "TripPin Part 2 - REST"
];

// Data Source UI publishing description
TripPin.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {"TripPin REST", "TripPin REST"}
];

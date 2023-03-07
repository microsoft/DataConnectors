section TripPin;

[DataSource.Kind = "TripPin", Publish = "TripPin.Publish"]
shared TripPin.Feed = Value.ReplaceType(TripPinImpl, type function (url as Uri.Type) as any);

TripPinImpl = (url as text) => let source = OData.Feed(url) in source;

// Data Source Kind description
TripPin = [
    // Declares the supported type(s) of authentication.
    // In this case, Implicit = Anonymous web access
    Authentication = [
        Anonymous = []
    ],
    // Assigns a label to the data source credential.
    // This will be displayed in the "Manage Data Sources" dialog.
    Label = "TripPin Part 1 - OData"
];

// Data Source UI publishing description
TripPin.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {"TripPin OData", "TripPin OData"}
];

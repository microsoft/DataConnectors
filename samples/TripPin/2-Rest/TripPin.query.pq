// Use this file to write queries to test your data connector
let
    result = TripPin.Feed("http://services.odata.org/v4/TripPinService/Me")
in
    result
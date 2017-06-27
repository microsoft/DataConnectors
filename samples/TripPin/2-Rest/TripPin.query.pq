//
// Use this file to write test queries to run from Visual Studio.
// Documentation: https://github.com/Microsoft/DataConnectors/blob/master/docs/m-extensions.md#query-file
//
let
    result = TripPin.Feed("http://services.odata.org/TripPinRESTierService/(S(dh0deax3pfzop331wyar1fep))/Me")
in
    result

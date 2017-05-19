// Use this file to write queries to test your data connector
let
    result = TripPin.Feed("http://services.odata.org/TripPinRESTierService/(S(dh0deax3pfzop331wyar1fep))/")
in
    result
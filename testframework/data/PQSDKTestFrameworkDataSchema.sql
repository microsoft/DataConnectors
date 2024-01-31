CREATE TABLE NyxTaxiGreen (
    recordId int,
    vendorID int,
    lpepPickupDatetime timestamp,
    lpepDropoffDatetime timestamp,
    storeAndFwdFlag string,
    rateCodeID int,
    puLocationId int,
    doLocationId int,
    passengerCount int,
    tripDistance double,
    fareAmount double,
    extra double,
    mtaTax double,
    tipAmount double,
    tollsAmount double,
    improvementSurcharge string,
    totalAmount double,
    paymentType int,
    tripType int,
    congestionSurcharge double
);

CREATE TABLE TaxiZoneLookup (
    LocationId int,
    Borough string,
    Zone string,
    service_zone string	
);
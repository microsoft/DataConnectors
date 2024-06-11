/*
NOTE: 
1) While uploading to the data source, all decimal values should have a scale of 2. That is, the number of digits after the decimal point should be 2. 
2) All timestamp values should be uploaded to the datasouce in MM/DD/YYYY HH24:MI:SS format.
*/

CREATE TABLE NycTaxiGreen (
    RecordID int,
    VendorID int,
    lpepPickupDatetime timestamp,
    lpepDropoffDatetime timestamp,
    storeAndFwdFlag boolean,
    RateCodeID int,
    PULocationID int,
    DOLocationID int,
    passenger_count int,
    trip_distance double,
    fare_amount double,
    extra double,
    mta_tax double,
    tip_amount double,
    tolls_amount double,
    improvement_surcharge double,
    total_amount double,
    payment_type int,
    trip_type int,
    congestion_surcharge double
);

CREATE TABLE TaxiZoneLookup (
    LocationId int,
    Borough string,
    Zone string,
    service_zone string	
);

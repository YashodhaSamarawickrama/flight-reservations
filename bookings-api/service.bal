import nuwandias/fares_api;
import nuwandias/inventory_api;
import ballerina/log;
import ballerina/http;
import ballerina/time;
import ballerina/url;

configurable string faresClientId = ?;
configurable string faresClientSecret = ?;
configurable string invClientId = ?;
configurable string invClientSecret = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service /bookings on new http:Listener(9090) {

    resource function post booking(@http:Payload Booking payload) returns BookingRecord|error? {

        log:printInfo("making a new booking: " + payload.toJsonString());

        inventory_api:Client inventory_apiEndpoint = check new ({auth: {clientId: invClientId, clientSecret: invClientSecret}});
        inventory_api:SeatAllocation postInventoryAllocateResponse = check inventory_apiEndpoint->postFlights({flightNumber: payload.flightNumber, flightDate: payload.flightDate, seats: payload.seats});

        //http:Client faresAPIEndpoint = check new ("https://82d26742-afe1-4ed2-bf5e-0034635f0a07-prod.e1-us-east-azure.choreoapis.dev/ecat/fares-api/1.0.0");
        //json fare = check faresAPIEndpoint->get("/fare/" + payload.flightNumber + "/" + check url:encode(payload.flightDate, "UTF-8"), headers = {"API-Key": "eyJraWQiOiJnYXRld2F5X2NlcnRpZmljYXRlX2FsaWFzIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJjOTlmM2Y3Ny1jYzgxLTQwMTgtOGFlZi1kYjhmMDQ2NTNiMTlAY2FyYm9uLnN1cGVyIiwiaXNzIjoiaHR0cHM6XC9cL3N0cy5jaG9yZW8uZGV2OjQ0M1wvb2F1dGgyXC90b2tlbiIsImtleXR5cGUiOiJQUk9EVUNUSU9OIiwic3Vic2NyaWJlZEFQSXMiOlt7InN1YnNjcmliZXJUZW5hbnREb21haW4iOm51bGwsIm5hbWUiOiJGYXJlcyBBUEkiLCJjb250ZXh0IjoiXC84MmQyNjc0Mi1hZmUxLTRlZDItYmY1ZS0wMDM0NjM1ZjBhMDdcL2VjYXRcL2ZhcmVzLWFwaVwvMS4wLjAiLCJwdWJsaXNoZXIiOiJjaG9yZW9fcHJvZF9hcGltX2FkbWluIiwidmVyc2lvbiI6IjEuMC4wIiwic3Vic2NyaXB0aW9uVGllciI6bnVsbH1dLCJleHAiOjE2NDcyODk3MDgsInRva2VuX3R5cGUiOiJJbnRlcm5hbEtleSIsImlhdCI6MTY0NzIyOTcwOCwianRpIjoiMDA2NTQ1YzktMzlkOC00MmYxLTgyYTQtNGY0Y2YwMGU4NjQ3In0.J5n4vBhF_Q1UCtiOE-JIHH5xW_PUBQkSRyMkKaZ2b1G7oqcJ25oyNINR-j10NqFyRbGsz5QDSMTMGcy9Ii5qhxl6XmZiS_afrj3r4nhq1ojxlVa81P4p8wduzLfipYxXLCaPMxjdHNsKpa7aq0LoLBqnIto7ygakmXXxBI9es0EwyIIpyPI6ufMj4H-b6OG_y8oVcmvKMDb1S9jgQo-X1_f1UcjZ70Snpji0XGPNLtHXciTiyxVrDf4CBlsY8OTRXs8p4yE1KFxNUT1ZIXl8ZOB7XkxfADcReZg3ISEtmckmA3g6hMkymRLqcz_TA-aszdsB4lA2OcekisJ7Pa1LuvyeT1iIxnpBh-vnC2btWu8wqnjbYPBNJXIfgQmGAh9g7w2F4uT3TXqQQP34jeidXLW5LB0ZXxhPV3n92KmOUKD3jNukAB8t9JgmsGV_ewayrXRh_coucDsMabwIvjfZ2o_ES0WGHjloJLx69PD00mcHn2aHDB44VY3ySM0Wbm9BviTI521VP0lSQIIPknxNIlMnG3I8HSMXvPe-vjUxDntLj1haQcSyTtQvhg7x8l0fT5vUcZ-0d8M5WzmYp8zhfl3arWGyJVBOi_by549zZxLH2HtsJeGJMwlorrRl4Q59ylbEwfSLv1aclOeFOw2oZmd8P3B7IpGB5xuHnsFnTWU"});
        fares_api:Client fares_apiEndpoint = check new ({auth: {clientId: faresClientId, clientSecret: faresClientSecret}});
        fares_api:Fare fare = check fares_apiEndpoint->getFareFlightnumberFlightdate(payload.flightNumber, check url:encode(payload.flightDate, "UTF-8"));
        BookingRecord newBooking = {
            id: bookingInventory.nextKey(),
            fare: <decimal>fare.fare,
            flightDate: payload.flightDate,
            origin: payload.origin,
            destination: payload.destination,
            bookingDate: currentDate(),
            flightNumber: payload.flightNumber,
            seats: payload.seats,
            status: BOOKING_CONFIRMED
        };

        BookingRecord saved = saveBookingRecord(newBooking);
        return saved;
    }

    resource function get booking/[int id]() returns BookingRecord|error? {
        return bookingInventory[id];
    }

    resource function post changestatus/[int id]/status/[string bookingStatus]() returns error? {
        BookingRecord? bookingRecord = bookingInventory[id];
        if bookingRecord is () {
            return error(string `unable to find the booking record, id: ${id}, booking status: ${bookingStatus}`);
        }
        bookingRecord.status = <BookingStatus>bookingStatus;
    }
}

type ApiCredentials record {|
    string clientId;
    string clientSecret;
|};

enum BookingStatus {
    NEW,
    BOOKING_CONFIRMED,
    CHECKED_IN
}

type Fare record {
    string flightNumber;
    string flightDate;
    decimal fare;
};

type BookingRecord record {
    readonly int id;
    string flightNumber;
    string origin;
    string destination;
    string flightDate;
    string bookingDate;
    decimal fare;
    int seats;
    BookingStatus status;
};

type Booking record {
    string flightNumber;
    string origin;
    string destination;
    string flightDate;
    int seats;
};

type Passenger record {
    string firstName;
    string lastName;
    string passportNumber;
};

table<BookingRecord> key(id) bookingInventory = table [

];

function saveBookingRecord(BookingRecord bookingRecord) returns BookingRecord {

    BookingRecord saved = {
        id: bookingInventory.nextKey(),
        fare: bookingRecord.fare,
        flightDate: bookingRecord.flightDate,
        origin: bookingRecord.origin,
        destination: bookingRecord.destination,
        bookingDate: bookingRecord.bookingDate,
        flightNumber: bookingRecord.flightNumber,
        seats: bookingRecord.seats,
        status: BOOKING_CONFIRMED
    };
    bookingInventory.add(saved);

    return saved;
}

function currentDate() returns string {
    time:Civil civil = time:utcToCivil(time:utcNow());
    return string `${civil.year}/${civil.month}/${civil.day}`;
}

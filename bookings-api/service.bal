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
        //json fare = check faresAPIEndpoint->get("/fare/" + payload.flightNumber + "/" + check url:encode(payload.flightDate, "UTF-8"), headers = {"API-Key": "XXXXXXXXX"});
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

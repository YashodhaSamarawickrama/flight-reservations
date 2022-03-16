import ballerinax/twilio;
import nuwandias/bookings_api;
import ballerina/log;
import ballerina/http;

configurable string twilioAccountSId = ?;
configurable string twilioAuthToken = ?;
configurable string bookingsClientId = ?;
configurable string bookingsClientSecret = ?;

type Reservation record {
    string flightNo;
    string flightDate;
    string origin;
    string destination;
    int seats;
    string contactNo;
};

service /flights on new http:Listener(9090) {

    resource function post reservation(@http:Payload Reservation reservation) returns Reservation|error? {

        log:printInfo("Received reservation request for " + reservation.flightNo);
        bookings_api:Client bookings_apiEndpoint = check new ({auth: {clientId: bookingsClientId, clientSecret: bookingsClientSecret}});
        bookings_api:BookingRecord bookingResponse = check bookings_apiEndpoint->postBooking({flightNumber: reservation.flightNo, origin: reservation.origin, destination: reservation.destination, flightDate: reservation.flightDate, seats: reservation.seats});
        twilio:Client twilioEndpoint = check new ({auth: {accountSId: twilioAccountSId, authToken: twilioAuthToken}}, {});
        twilio:SmsResponse smsResponse = check twilioEndpoint->sendSms("+18312449432", reservation.contactNo, "Booking confirmed for flight " + reservation.flightNo);
        return reservation;
    }
}

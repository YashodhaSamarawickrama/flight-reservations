import ballerina/http;

type Fare record {
    string flightNo;
    string flightDate;
    float fare;
};

service /fares on new http:Listener(9090) {

    resource function post fare(@http:Payload Fare fare) returns Fare|error? {

    }
    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get fare/[string flightNumber]/[string flightDate]() returns Fare|error {
        Fare fare = {flightNo: flightNumber, flightDate: flightDate, fare: 127.54};
        return fare;
    }
}

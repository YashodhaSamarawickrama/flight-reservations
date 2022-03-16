import ballerina/log;
import nuwandias/fares_api;

configurable string faresClientId = ?;
configurable string faresClientSecret = ?;

public function main() returns error? {

    log:printInfo("Executing the fare update process");
    fares_api:Fare fare = {"flightNo": "FL1", "flightDate": "2022/03/15", "fare": 542.65};
    fares_api:Client fares_apiEndpoint = check new ({auth: {clientId: faresClientId, clientSecret: faresClientSecret}});
    fares_api:Fare updatedFare = check fares_apiEndpoint->postFare(fare);
}

import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.

type FlightDetails record {
    string flightNumber;
    string airline;
    string flightDate;
    string origin;
    string destination;
    int available;
    int totalCapacity;
    int baseFare;
};

service /fareCal on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get fareCalculator(string flightNo, int noOfPassengers) returns int|error {
        int noOfSeatsAvaible;
        int totalCapacity;
        int totalFare = 0;
        int baseFare;
        jdbc:Client jdbcEndpoint = check new ("jdbc:sqlserver://flightreservationsystem.database.windows.net:1433;database=flightdata;user=Yashodha123@flightreservationsystem;password=123Newyork@#1;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;");
        stream<FlightDetails, error?> resultStream1 = jdbcEndpoint->query(`SELECT * from Flight WHERE flightNumber=${flightNo}`);
        check from FlightDetails flight in resultStream1
            do {
                baseFare = flight["baseFare"];
                // io:println("Base fare for this flight is :", baseFare);
                noOfSeatsAvaible = flight["available"];
                // io:println("Seats available: ", noOfSeatsAvaible);
                totalCapacity = flight["totalCapacity"];
                // io:println("Total capacity: ", flight["totalCapacity"]);
            };
        totalFare = calculateFare(totalCapacity, noOfSeatsAvaible, baseFare, noOfPassengers);
        io:println(string `Total fare : ${totalFare}`);
        return totalFare;
    }
}

function calculateFare(int totalCapacity, int available, int baseFare, int noOfPassengers) returns int {
    io:println("Calculated fare for this flight : ");
    io:println(string `Total capacity: ${totalCapacity}`);
    io:println(string `Number of seats availabl seats: ${available}`);
    io:println(string `Base fare for this flight: ${baseFare}`);
    io:println(string `Number of passengers: ${noOfPassengers}`);
    int priceIncrementPerSeat = baseFare * ((totalCapacity - available) /totalCapacity);
    return (baseFare + priceIncrementPerSeat) * noOfPassengers;
}

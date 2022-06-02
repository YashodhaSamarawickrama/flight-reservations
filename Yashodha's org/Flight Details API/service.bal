import ballerinax/java.jdbc;
import ballerina/http;
import ballerina/io;

type FlightDetails record {
    string flightNumber;
    string airline;
    string flightDate;
    string flightTimeInLocalTime;
    string origin;
    string destination;
    int available;
    int totalCapacity;
};

service / on new http:Listener(8090) {
    resource function get flightdata(string destination, string origin, string date, string? flightNo) returns FlightDetails|error {
        io:println("This API endpoint will return details of all available flights");
        jdbc:Client jdbcEndpoint = check new ("jdbc:sqlserver://flightreservationsystem.database.windows.net:1433;database=flightdata;user=Yashodha123@flightreservationsystem;password=123Newyork@#1;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;");
        // stream<FlightDetails, error?> resultStream = jdbcEndpoint->query(`SELECT * FROM Flight`);
        // check from FlightDetails flight in resultStream
            // do {
            //     io:println("Flight number: ", flight["flightNumber"]);
            //     io:println("Airline: ", flight["airline"]);
            //     io:println("Flight date: ", flight["flightDate"]);
            //     io:println("Origin: ", flight["origin"]);
            //     io:println("Destination: ", flight["destination"]);
            //     io:println("Seats available: ", flight["available"]);
            //     io:println("Total capacity: ", flight["totalCapacity"]);
            // };
        // if(flightNo != ""){
        //     stream<FlightDetails, error?> resultStream1 = jdbcEndpoint->query(`SELECT * from Flight WHERE flightNumber=${flightNo}`);
        // check from FlightDetails flight in resultStream1
        //     do {
        //         io:println("Flight number: ", flight["flightNumber"]);
        //         io:println("Airline: ", flight["airline"]);
        //         io:println("Flight date: ", flight["flightDate"]);
        //         io:println("Origin: ", flight["origin"]);
        //         io:println("Destination: ", flight["destination"]);
        //         io:println("Seats available: ", flight["available"]);
        //         io:println("Total capacity: ", flight["totalCapacity"]);
        //     };
        // }
    //    if(destination !=""){
    //         stream<FlightDetails, error?> resultStream1 = jdbcEndpoint->query(`SELECT * from Flight WHERE destination=${destination}`);
    //         check from FlightDetails flight in resultStream1
    //         do {
    //             io:println("Flight number: ", flight["flightNumber"]);
    //             io:println("Airline: ", flight["airline"]);
    //             io:println("Flight date: ", flight["flightDate"]);
    //             io:println("Origin: ", flight["origin"]);
    //             io:println("Destination: ", flight["destination"]);
    //             io:println("Seats available: ", flight["available"]);
    //             io:println("Total capacity: ", flight["totalCapacity"]);
    //         };
    //     }
        if(destination !="" && origin !="" && date !=""){
            stream<FlightDetails, error?> resultStream1 = jdbcEndpoint->query(`SELECT * from Flight WHERE(origin=${origin} AND destination=${destination} AND flightDate=${date})`);
            check from FlightDetails flight in resultStream1
            do {
                io:println("Flight number: ", flight["flightNumber"]);
                io:println("Airline: ", flight["airline"]);
                io:println("Flight date: ", flight["flightDate"]);
                io:println("Flight time in (local time): ", flight["flightTimeInLocalTime"]);
                io:println("Origin: ", flight["origin"]);
                io:println("Destination: ", flight["destination"]);
                io:println("Seats available: ", flight["available"]);
                io:println("Total capacity: ", flight["totalCapacity"]);
            };
        }
        else {
            io:println("Please add valid inputs");
        }

    }
}

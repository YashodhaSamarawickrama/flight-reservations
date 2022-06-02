import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/io;

# A service representing a network-accessible API
# bound to port `9090`.

type CustomerDetails record {
   string customerId;
   string passportNo;
   string residentialAddress;
   string name;
   string email;
   string phone;
 };

service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function post registerCustomer(string passportNo, string name,string address, string email, string phone) returns string|error? {
        jdbc:Client jdbcEndpoint = check new ("jdbc:sqlserver://flightreservationsystem.database.windows.net:1433;database=flightdata;user=Yashodha123@flightreservationsystem;password=*******;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;");
        stream<CustomerDetails, error?> resultStream = jdbcEndpoint -> query(`INSERT INTO Customer(passportNo,name,residentialAddress,email,phone) VALUES(${passportNo},${name},${address},${email},${phone}) `);
        // check from ReservationDetails resevation in resultStream
        //     do {
        //         baseFare = flight["baseFare"];
        //         // io:println("Base fare for this flight is :", baseFare);
        //         noOfSeatsAvaible = flight["available"];
        //         // io:println("Seats available: ", noOfSeatsAvaible);
        //         totalCapacity = flight["totalCapacity"];
        //         // io:println("Total capacity: ", flight["totalCapacity"]);
        //     };
        io:println(resultStream);
        return "";

    }
}

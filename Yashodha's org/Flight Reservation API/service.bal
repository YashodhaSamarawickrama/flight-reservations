import wso2/choreo.sendemail;
import ballerina/http;
import ballerinax/java.jdbc;

# A service representing a network-accessible API
# bound to port `9090`.

type ReservationDetails record {
    string reservationId;
    string passportNo;
    string name;
    string email;
    string flightNo;
    int noOfPassengers;
};

type FlightDetails record {
    string flightNumber;
    string airline;
    string origin;
    string destination;
    int available;
    int totalCapacity;
    string flightDate;
    int baseFare;
    string checkInTime;
    string boardingTime;
    string gate;
    string flightTimeInUTC;
    string flightTimeInLocalTime;
};

string customerEmail = "";

service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function post createReservation(string passportNo, string name, string email, string flightNo, int noOfPassengers) returns string|error? {
        customerEmail = email;
        string airline;
        string flightDate;
        string origin;
        string destination;
        string flightTimeInUTC;
        string flightTimeInLocalTime;
        jdbc:Client jdbcEndpoint = check new ("jdbc:sqlserver://flightreservationsystem.database.windows.net:1433;database=flightdata;user=Yashodha123@flightreservationsystem;password=123Newyork@#1;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;");
        stream<FlightDetails, error?> flightTimeRes = jdbcEndpoint->query(`SELECT * from Flight where flightNumber=${flightNo}`);
        check from FlightDetails flight in flightTimeRes
            do {
                airline = flight["airline"];
                origin = flight["origin"];
                destination = flight["destination"];
                flightDate = flight["flightDate"];
                flightTimeInLocalTime = flight["flightTimeInLocalTime"];
                flightTimeInUTC = flight["flightTimeInUTC"];
            };
        stream<ReservationDetails, error?> resultStream = jdbcEndpoint->query(`INSERT INTO Reservation(passportNo,name,email,flightNo,noOfPassengers) VALUES(${passportNo},${name},${email},${flightNo},${noOfPassengers}) `);
        sendemail:Client sendemailEndpoint = check new ({});
        string sendEmailResponse1 = check sendemailEndpoint->sendEmail(customerEmail, "Flight reservation confirmation", "Your reservation is successful.Please note the itinerary details below"+"\n"+"Flight Number:" + flightNo+"\n"+ "Airline :" + airline +"\n"+ "Origin :" + origin +"\n"+"Destination :" + destination +"\n"+"Flight date :" + flightDate +"\n"+"Flight time :" + flightTimeInLocalTime);
        return "";

    }
}

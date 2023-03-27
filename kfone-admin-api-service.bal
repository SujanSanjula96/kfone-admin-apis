import ballerina/http;

listener http:Listener httpListener = new (9090);

service / on httpListener {
    resource function get devices() returns string { 
        return "All Devices"; 
    }

    resource function get devices/[string deviceName]() returns string { 
        return deviceName; 
    }
}

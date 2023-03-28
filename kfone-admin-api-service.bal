import kfone_admin_apis.dao;
import ballerina/http;
import kfone_admin_apis.utils;

listener http:Listener httpListener = new (9090);

service / on httpListener {
    resource function get devices() returns utils:Device[]|string { 
        utils:Device[]|string devices = dao:getDevices();
        return devices;
    }

    resource function get devices/[string deviceName]() returns string { 
        return deviceName; 
    }

    resource function post devices(@http:Payload utils:Device payload) returns string { 
        string response = dao:addDevice(
            payload.id, 
            payload.name, 
            payload.description ?: "", 
            payload.category, 
            payload.imageUrl ?: "",
            payload.price
        );
        return response;
    }
}

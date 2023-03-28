import ballerina/http;
import kfone_admin_apis.config;
import kfone_admin_apis.utils;

listener http:Listener httpListener = new (9090);

service / on httpListener {
    resource function get devices() returns utils:Device[]|string { 
        return config:foo;
    }

    resource function get devices/[string deviceName]() returns string { 
        return config:foo; 
    }

    resource function post devices(@http:Payload utils:Device payload) returns string { 
        return config:foo;
    }
}

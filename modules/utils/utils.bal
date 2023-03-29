import ballerina/http;
import kfone_admin_apis.config;
import ballerina/log;
import ballerina/mime;

public function getAccessToken() returns string|error {
    
    http:Client|error clientTokenEndpoint = new(config:tokenEndpoint, httpVersion = http:HTTP_1_1);

    if clientTokenEndpoint is error {
        return clientTokenEndpoint;
    }
    log:printInfo("Token Client endpoint created");

    string clientCredentials = config:systemAppClientID + ":" + config:systemAppClientSecret;
    string encodedString = clientCredentials.toBytes().toBase64();

    json|error tokenResponse = clientTokenEndpoint->post(
        "/token",
        {
            "grant_type": "client_credentials",
            "scope": "SYSTEM"
        },
        {
            "Authorization": string `Basic ${encodedString}`
        },
        mime:APPLICATION_FORM_URLENCODED
    );

    string accessToken = "";
    if (tokenResponse is json) {
        json|error accessTokenField =  tokenResponse.access_token;
        if (accessTokenField is json) {
            accessToken = accessTokenField.toString();
        } else {
            return accessTokenField;
        }
    } else {
        return tokenResponse;
    }
    log:printInfo("Access Token: " + accessToken);
    return accessToken;
}

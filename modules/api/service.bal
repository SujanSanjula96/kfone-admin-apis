import ballerina/http;
import kfone_admin_apis.utils;
import kfone_admin_apis.config;
import ballerina/log;
import ballerina/mime;

public function getUsers() returns http:Response|string {

    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        return accessToken.message();
    }

    http:Client|error scimEndpoint = new(config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        return scimEndpoint.message();
    }

    log:printInfo("Client endpoint created");

    http:Response|error response = scimEndpoint->get(
        "/Users?domain=DEFAULT&filter=groups+eq+" + config:customerGroupName,
        {
            "Authorization": string `Bearer ${accessToken}`,
            "Accept": mime:APPLICATION_JSON
        }
    );

    if (response is http:Response) {
        string|error text = response.getTextPayload();
        if text is string {
            return text;
        } else {
            return text.message();
        }
        
    } else {
        return response.message();
    }
}

public function createUser(utils:UserPostModel user) returns http:Response|string {

    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        return accessToken.message();
    }

    http:Client|error scimEndpoint = new(config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        return scimEndpoint.message();
    }

    log:printInfo("Client endpoint created");

    http:Response|error response = scimEndpoint->post(
        "/Users",
        {
            "schemas": 
                [
                    "urn:ietf:params:scim:schemas:core:2.0:User",
                    "urn:scim:wso2:schema"
                ],
            "name":{
                "familyName":user.familyName,
                "givenName":user.givenName
            },
            "password":user.password,
            "userName": string `DEFAULT/${user.username}`,
            "emails":[
                {
                    "primary":true,
                    "value":user.username
                }
            ],
            "urn:scim:wso2:schema": {
                "tier": user.tier,
                "tierPoints": user.tierPoints
            }
        },
        {
            "Authorization": string `Bearer ${accessToken}`,
            "Accept": mime:APPLICATION_JSON
        }
    );

    if (response is http:Response) {
        string|error text = response.getTextPayload();
        json|error userId = response.getJsonPayload();
        if userId is error {
            return userId.message();
        }
        json|error userIdJson = userId.id;
        if userIdJson is error {
            return userIdJson.message();
        }
        string userIdString = userIdJson.toString();

        http:Response|string responseGroup = addUserToCustomerGroup(user.username, userIdString);
        if text is string {
            return text;
        } else {
            return text.message();
        }
        
    } else {
        return response.message();
    }
}

public function updateUser(utils:UserPatchModel user) returns http:Response|string {

    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        return accessToken.message();
    }

    http:Client|error scimEndpoint = new(config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        return scimEndpoint.message();
    }

    log:printInfo("Client endpoint created");

    http:Response|error response = scimEndpoint->patch(
        string `/Users/${user.userId}`,
        {
            "Operations":[
                {
                    "op":"replace",
                    "value":{
                        "urn:scim:wso2:schema":{
                            "tierPoints":user.tierPoints,
                            "tier":user.tier
                        }
                    }
                }
            ],
            "schemas":["urn:ietf:params:scim:api:messages:2.0:PatchOp"]
        },
        {
            "Authorization": string `Bearer ${accessToken}`,
            "Accept": mime:APPLICATION_JSON
        }
    );

    if (response is http:Response) {
        string|error text = response.getTextPayload();
        if text is string {
            return text;
        } else {
            return text.message();
        }
        
    } else {
        return response.message();
    }
}

function addUserToCustomerGroup(string userName, string userId) returns http:Response|string {
    
    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        return accessToken.message();
    }

    http:Client|error scimEndpoint = new(config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        return scimEndpoint.message();
    }

    log:printInfo("Client endpoint created");

    http:Response|error response = scimEndpoint->patch(
        string `/Groups/${config:customerGroupId}`,
        {
            "Operations":[
                {
                    "op":"add",
                    "value":{
                        "members":[
                            {
                                "display": string `DEFAULT/${userName}`,
                                "value": userId
                            }
                        ]
                    }
                }
            ],
            "schemas":["urn:ietf:params:scim:api:messages:2.0:PatchOp"]
        },
        {
            "Authorization": string `Bearer ${accessToken}`,
            "Accept": mime:APPLICATION_JSON
        }
    );

    if (response is http:Response) {
        string|error text = response.getTextPayload();
        if text is string {
            return text;
        } else {
            return text.message();
        }
        
    } else {
        return response.message();
    }
}

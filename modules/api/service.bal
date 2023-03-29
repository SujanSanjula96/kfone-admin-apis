import ballerina/http;
import kfone_admin_apis.utils;
import kfone_admin_apis.config;
import ballerina/log;
import ballerina/mime;

public function updateUserDetails(string userName, string userId) returns http:Response|string {
    
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

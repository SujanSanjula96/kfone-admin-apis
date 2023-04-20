import ballerina/http;
import kfone_admin_apis.utils;
import kfone_admin_apis.config;
import ballerina/log;
import ballerina/mime;
import kfone_admin_apis.dao;
import ballerina/uuid;

public function getDevices() returns utils:Device[]|http:InternalServerError {

    utils:Device[]|error devices = dao:getDevices();

    if devices is error {
        return <http:InternalServerError> {body: "Error while retrieving devices."};
    }

    return devices;
}

public function addDevice(utils:Device device) returns http:Created|http:InternalServerError {

    string id = uuid:createType1AsString();
    error? result = dao:addDevice(
        id,
        device.name,
        device.description ?: "",
        device.category,
        device.imageUrl ?: "",
        device.price
    );

    if result is error {
        return <http:InternalServerError> {body: "Error while adding device."};
    }

    return http:CREATED;
}

public function deleteDevice(string id) returns http:NoContent|http:InternalServerError {

    error? result = dao:deleteDevice(id);

    if result is error {
        return <http:InternalServerError> {body: "Error while deleting device."};
    }

    return http:NO_CONTENT;
}

public function getPromos() returns utils:Promo[]|http:InternalServerError {

    utils:Promo[]|error promos = dao:getPromos();

    if promos is error {
        return <http:InternalServerError> {body: "Error while retrieving promos."};
    }
    
    return promos;
}

public function addPromo(utils:Promo promo) returns http:Created|http:InternalServerError {

    string id = uuid:createType1AsString();
    error? result = dao:addPromo(
        id,
        promo.promoCode,
        promo.discount
    );

    if result is error {
        return <http:InternalServerError> {body: "Error while adding promo."};
    }

    return http:CREATED;
}

public function getPromo(string promoId) returns utils:Promo|http:NotFound|http:InternalServerError {

    utils:Promo?|error promo = dao:getPromo(promoId);

    if promo is error {
        return <http:InternalServerError> {body: "Error while getting promo."};
    }
    if promo is () {
        return <http:NotFound> {body: "Promo not found."};
    }

    return promo;
}

public function deletePromo(string promoId) returns http:NoContent|http:InternalServerError {

    error? result = dao:deletePromo(promoId);

    if result is error {
        return <http:InternalServerError> {body: "Error while deleting promo."};
    }

    return http:NO_CONTENT;
}

public function updatePromoInDevice(utils:UpdatePromoInDevicesRequest payload, string deviceId) returns http:Ok|http:InternalServerError {

    string removedPromoId = payload.removedPromoId;
    string addedPromoId = payload.addedPromoId;

    if (addedPromoId != "") {
        error? result = dao:addPromoToDevice(deviceId, addedPromoId);
        if result is error {
            return <http:InternalServerError> {body: result.message()};
        }
    }
    if (removedPromoId != "") {
        error? result = dao:deletePromoFromDevice(deviceId);
        if result is error {
            return <http:InternalServerError> {body: result.message()};
        }
    }
    
    return http:OK;
}

public function getUsers() returns http:Response|error {

    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        return accessToken;
    }

    http:Client|error scimEndpoint = new (config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        return scimEndpoint;
    }

    http:Response|error response = scimEndpoint->get(
        "/Users?domain=DEFAULT&filter=groups+eq+" + config:customerGroupName,
        {
        "Authorization": string `Bearer ${accessToken}`,
        "Accept": mime:APPLICATION_JSON
    }
    );

    return response;
}

public function createUser(utils:UserPostModel user) returns http:Response|error {

    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        return accessToken;
    }

    http:Client|error scimEndpoint = new (config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        return scimEndpoint;
    }

    http:Response|error response = scimEndpoint->post(
        "/Users",
        {
        "schemas":
                [
            "urn:ietf:params:scim:schemas:core:2.0:User",
            "urn:scim:wso2:schema"
        ],
        "name": {
            "familyName": user.familyName,
            "givenName": user.givenName
        },
        "password": user.password,
        "userName": string `DEFAULT/${user.username}`,
        "emails": [
            {
                "primary": true,
                "value": user.username
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

        if (response.statusCode != 201) {
            return response;
        }

        json|error responsePayload = response.getJsonPayload();
        if responsePayload is error {
            return responsePayload;
        }
        json|error userIdJson = responsePayload.id;
        if userIdJson is error {
            return userIdJson;
        }
        string userIdString = userIdJson.toString();
        _ = addUserToCustomerGroup(user.username, userIdString);
    }

    return response;
}

public function updateUser(utils:UserPatchModel user) returns http:Response|error {

    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        return accessToken;
    }

    http:Client|error scimEndpoint = new (config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        return scimEndpoint;
    }

    http:Response|error response = scimEndpoint->patch(
        string `/Users/${user.userId}`,
        {
        "Operations": [
            {
                "op": "replace",
                "value": {
                    "urn:scim:wso2:schema": {
                        "tierPoints": user.tierPoints,
                        "tier": user.tier
                    }
                }
            }
        ],
        "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"]
    },
        {
        "Authorization": string `Bearer ${accessToken}`,
        "Accept": mime:APPLICATION_JSON
    }
    );

    return response;
}

function addUserToCustomerGroup(string userName, string userId) {

    string|error accessToken = utils:getAccessToken();
    if accessToken is error {
        log:printError(accessToken.message());
        return;
    }

    http:Client|error scimEndpoint = new (config:scimEndpoint, httpVersion = http:HTTP_1_1);

    if scimEndpoint is error {
        log:printError(scimEndpoint.message());
        return;
    }

    http:Response|error response = scimEndpoint->patch(
        string `/Groups/${config:customerGroupId}`,
        {
        "Operations": [
            {
                "op": "add",
                "value": {
                    "members": [
                        {
                            "display": string `DEFAULT/${userName}`,
                            "value": userId
                        }
                    ]
                }
            }
        ],
        "schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"]
    },
        {
        "Authorization": string `Bearer ${accessToken}`,
        "Accept": mime:APPLICATION_JSON
    }
    );
}

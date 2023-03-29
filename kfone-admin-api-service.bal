import kfone_admin_apis.dao;
import ballerina/http;
import kfone_admin_apis.utils;
import ballerina/uuid;
import ballerina/log;
import kfone_admin_apis.config;
import ballerina/mime;

listener http:Listener httpListener = new (9090);

service / on httpListener {
    resource function get devices() returns utils:Device[]|http:InternalServerError { 

        return dao:getDevices();
    }

    resource function get devices/[string deviceName]() returns string { 
        return deviceName; 
    }

    resource function post devices(@http:Payload utils:Device payload) returns http:Created|http:InternalServerError { 

        string id = uuid:createType1AsString();
        return  dao:addDevice(
            id, 
            payload.name, 
            payload.description ?: "", 
            payload.category, 
            payload.imageUrl ?: "",
            payload.price
        );
    }

    resource function delete devices/[string deviceId]() returns http:NoContent|http:InternalServerError {
        
        return dao:deleteDevice(deviceId);
    }

    resource function get promos() returns utils:Promo[]|http:InternalServerError { 

        return dao:getPromos();
    }
    
    resource function post promos(@http:Payload utils:Promo payload) returns http:Created|http:InternalServerError{ 

        string id = uuid:createType1AsString();
    
        return dao:addPromo(
            id,
            payload.promoCode, 
            payload.discount
        );
    }

    resource function get promos/[string promoId]() returns utils:Promo|http:NotFound|http:InternalServerError {
        
        return dao:getPromo(promoId);
    }

    resource function delete promos/[string promoId]() returns http:NoContent|http:InternalServerError {
        
        return dao:deletePromo(promoId);
    }

     resource function patch devices/[string deviceId]/promos(@http:Payload utils:UpdatePromoInDevicesRequest payload) returns http:Ok|http:NotFound|http:InternalServerError {
        
        string removedPromoId = payload.removedPromoId;
        string addedPromoId = payload.addedPromoId;

        if (addedPromoId != "") {
            return dao:addPromoToProduct(deviceId, addedPromoId);
            }
        if (removedPromoId != "") {
            return dao:deletePromoFromProduct(deviceId);
        }
        return http:OK;
    }

    resource function get getUsers() returns http:Response|string {

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
            "/Users",
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

    resource function post createUser(@http:Payload utils:UserPostModel user) returns http:Response|string {

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
                "emails":[
                    {
                        "primary":true,
                        "value":user.username
                    }
                ],
                "name":{
                    "familyName":user.familyName,
                    "givenName":user.givenName
                },
                "password":user.password,
                "userName": string `DEFAULT/${user.username}`
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
}

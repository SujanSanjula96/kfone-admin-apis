import kfone_admin_apis.dao;
import ballerina/http;
import kfone_admin_apis.utils;
import ballerina/uuid;
import kfone_admin_apis.api;

listener http:Listener httpListener = new (9090);

service / on httpListener {

    resource function get devices() returns utils:Device[]|http:InternalServerError { 

        return dao:getDevices();
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

    resource function get getUsers() returns http:Response|error {

        return api:getUsers();
    }

    resource function post createUser(@http:Payload utils:UserPostModel user) returns http:Response|error {

        return api:createUser(user);
    }
    
    resource function patch updateUser(@http:Payload utils:UserPatchModel user) returns http:Response|error {

        return api:updateUser(user);
    }
}

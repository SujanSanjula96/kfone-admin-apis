import ballerina/http;
import kfone_admin_apis.utils;
import kfone_admin_apis.api;

listener http:Listener httpListener = new (9090);

service / on httpListener {

    resource function get devices() returns utils:Device[]|http:InternalServerError {

        return api:getDevices();
    }

    resource function post devices(@http:Payload utils:Device payload) returns http:Created|http:InternalServerError {

        return  api:addDevice(payload);
    }

    resource function delete devices/[string deviceId]() returns http:NoContent|http:InternalServerError {

        return api:deleteDevice(deviceId);
    }

    resource function get promos() returns utils:Promo[]|http:InternalServerError {

        return api:getPromos();
    }

    resource function post promos(@http:Payload utils:Promo payload) returns http:Created|http:InternalServerError {

        return api:addPromo(payload);
    }

    resource function get promos/[string promoId]() returns utils:Promo|http:NotFound|http:InternalServerError {

        return api:getPromo(promoId);
    }

    resource function delete promos/[string promoId]() returns http:NoContent|http:InternalServerError {

        return api:deletePromo(promoId);
    }

    resource function patch devices/[string deviceId]/promos(@http:Payload utils:UpdatePromoInDevicesRequest payload) returns http:Ok|http:InternalServerError {

        return api:updatePromoInDevice(payload, deviceId);
    }

    resource function get getUsers() returns http:Response|http:InternalServerError {

        http:Response|error response = api:getUsers();
        if (response is error) {
            return <http:InternalServerError> {body: "Error while retrieving the users."};
        }
        return response;
    }

    resource function post createUser(@http:Payload utils:UserPostModel user) returns http:Response|http:InternalServerError {

        http:Response|error response = api:createUser(user);
        if (response is error) {
            return <http:InternalServerError> {body: "Error while creating the user."};
        }
        return response;
    }

    resource function patch updateUser(@http:Payload utils:UserPatchModel user) returns http:Response|http:InternalServerError {

        http:Response|error response = api:updateUser(user);
        if (response is error) {
            return <http:InternalServerError> {body: "Error while updating the tier of the user."};
        }
        return response;
    }
}

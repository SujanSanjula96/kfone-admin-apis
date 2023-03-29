import kfone_admin_apis.utils;
import kfone_admin_apis.config;
import ballerinax/mongodb;
import ballerina/http;

mongodb:ConnectionConfig mongoConfig = {
    connection: {
        url: config:dBConnectionUrl
    },
    databaseName: config:dbCluster
};
mongodb:Client mongoClient = check new (mongoConfig);

public function getDevices() returns utils:Device[]|http:InternalServerError {
    stream<utils:Device, error?>|mongodb:Error result = checkpanic mongoClient->find("devicesTest", (), ());

    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }

    utils:Device[] deviceList = [];
    if result is stream<utils:Device, error?> {
        if result is stream<utils:Device> {
            foreach var item in result {
                utils:Device device = {
                    name: item.name,
                    price: item.price,
                    imageUrl: item.imageUrl,
                    description: item.description,
                    id: item.id,
                    category: item.category,
                    promos: item?.promos
                };
                deviceList.push(device);
            }
        }
    }
    return deviceList;
}

public function addDevice(string id, string name, string description, string category, string imageUrl, float price) returns http:Created|http:InternalServerError {

    map<json> device = {
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
        category: category,
        promos: null
    };
    mongodb:Error? result = checkpanic mongoClient->insert(device,"devicesTest");
    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }
    return http:CREATED;
}

public function deleteDevice(string id) returns http:NoContent|http:InternalServerError {

    int|mongodb:Error result = checkpanic mongoClient->delete("devicesTest", (), {id: id});
    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }
    return http:NO_CONTENT;
}
public function addPromo(string id, string promoCode, float discount) returns http:Created|http:InternalServerError {

    map<json> promotion = {
        id: id,
        promoCode: promoCode,
        discount: discount
    };
    mongodb:Error? result = checkpanic mongoClient->insert(promotion,"promotions");
    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }
    return http:CREATED;
}

public function getPromos() returns utils:Promo[]|http:InternalServerError {
    stream<utils:Promo, error?>|mongodb:Error result = checkpanic mongoClient->find("promotions", (), ());

    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }

    utils:Promo[] promotionsList = [];
    if result is stream<utils:Promo, error?> {
        if result is stream<utils:Promo> {
            foreach var item in result {
                utils:Promo promotion = {
                    id: item.id,
                    promoCode: item.promoCode,
                    discount: item.discount
                };
                promotionsList.push(promotion);
            }
        }
    }
    return promotionsList;
}

public function getPromo(string promoId) returns utils:Promo|http:NotFound|http:InternalServerError {

        stream<utils:Promo, error?>|mongodb:Error result = checkpanic mongoClient->find("promotions", (), {id: promoId});

    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }
    utils:Promo? promo = ();
    if result is stream<utils:Promo, error?> {
        if result is stream<utils:Promo> {
            foreach var item in result {
                promo = {
                    id: item.id,
                    promoCode: item.promoCode,
                    discount: item.discount
                };  
            }
        }
    }

    if promo is ()  {
        return http:NOT_FOUND;
    }
    return promo;
}

public function deletePromo(string promoId) returns http:InternalServerError|http:NoContent {

    int|mongodb:Error result = checkpanic mongoClient->delete("promotions", (), {id: promoId});
    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }
    return http:NO_CONTENT;
}

public function addPromoToProduct(string productId, string promoId) returns http:Ok|http:NotFound|http:InternalServerError {

    utils:Promo|http:NotFound|http:InternalServerError promo = getPromo(promoId);
    if promo is http:NotFound {
        return http:NOT_FOUND;
    }
    else if promo is http:InternalServerError {
        return http:INTERNAL_SERVER_ERROR;
    }
    else if promo is utils:Promo {

        map<json> promotion = {
            id: promo.id,
            promoCode: promo.promoCode,
            discount: promo.discount
        };        

        int|mongodb:Error? result = checkpanic mongoClient->update({ "$set": { promos: promotion}}, "devicesTest", (), {id: productId});
        if result is mongodb:Error {
            return http:INTERNAL_SERVER_ERROR;
        }
    }
    return http:OK;
}

public function deletePromoFromProduct(string productId) returns http:Ok|http:InternalServerError {

    int|mongodb:Error? result = checkpanic mongoClient->update({ "$set": { promos: null}}, "devicesTest", (), {id: productId});
    if result is mongodb:Error {
        return http:INTERNAL_SERVER_ERROR;
    }
    return http:OK;
}

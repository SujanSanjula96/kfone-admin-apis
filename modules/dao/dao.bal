import kfone_admin_apis.utils;
import kfone_admin_apis.config;
import ballerinax/mongodb;

mongodb:ConnectionConfig mongoConfig = {
    connection: {
        url: config:dBConnectionUrl
    },
    databaseName: config:dbCluster
};
mongodb:Client mongoClient = check new (mongoConfig);

public function getDevices() returns utils:Device[]|error {

    stream<utils:Device, error?>|mongodb:Error result = checkpanic mongoClient->find(utils:DEVICE_COLLECTION, (), ());

    if result is mongodb:Error {
        return result;
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

public function addDevice(string id, string name, string description, string category, string imageUrl, float price) returns error? {

    map<json> device = {
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
        category: category,
        promos: null
    };
    mongodb:Error? result = checkpanic mongoClient->insert(device, utils:DEVICE_COLLECTION);
    if result is mongodb:Error {
        return result;
    }
}

public function deleteDevice(string id) returns error? {

    int|mongodb:Error result = checkpanic mongoClient->delete(utils:DEVICE_COLLECTION, (), {id: id});
    if result is mongodb:Error {
        return result;
    }
}

public function getPromos() returns utils:Promo[]|error {
    stream<utils:Promo, error?>|mongodb:Error result = checkpanic mongoClient->find(utils:PROMOTION_COLLECTION, (), ());

    if result is mongodb:Error {
        return result;
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

public function addPromo(string id, string promoCode, float discount) returns error? {

    map<json> promotion = {
        id: id,
        promoCode: promoCode,
        discount: discount
    };
    mongodb:Error? result = checkpanic mongoClient->insert(promotion, utils:PROMOTION_COLLECTION);
    if result is mongodb:Error {
        return result;
    }
}

public function getPromo(string promoId) returns utils:Promo?|error {

    stream<utils:Promo, error?>|mongodb:Error result = checkpanic mongoClient->find(utils:PROMOTION_COLLECTION, (), {id: promoId});

    if result is mongodb:Error {
        return result;
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

    return promo;
}

public function deletePromo(string promoId) returns error? {

    int|mongodb:Error result = checkpanic mongoClient->delete(utils:PROMOTION_COLLECTION, (), {id: promoId});
    if result is mongodb:Error {
        return result;
    }
}

public function addPromoToDevice(string productId, string promoId) returns error? {

    utils:Promo?|error promo = getPromo(promoId);
    if promo is error {
        return promo;
    } 

    if promo is utils:Promo {
        map<json> promotion = {
            id: promo.id,
            promoCode: promo.promoCode,
            discount: promo.discount
        };

        int|mongodb:Error? result = checkpanic mongoClient->update({"$set": {promos: promotion}}, utils:DEVICE_COLLECTION, (), {id: productId});
        if result is mongodb:Error {
            return error("Error while adding promotion to device.");
        }
        return;
    }

    return error("Promotion not found.");
}

public function deletePromoFromDevice(string productId) returns error? {

    int|mongodb:Error? result = checkpanic mongoClient->update({"$set": {promos: null}}, utils:DEVICE_COLLECTION, (), {id: productId});
    if result is mongodb:Error {
        return error("Error while deleting promotion from product");
    }
}

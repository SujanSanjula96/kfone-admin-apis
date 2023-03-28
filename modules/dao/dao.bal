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

public function getDevices() returns utils:Device[]|string {
    stream<utils:Device, error?>|mongodb:Error result = checkpanic mongoClient->find("devicesTest1", (), ());

    if result is mongodb:Error {
        return "Error";
    }

    utils:Device[] deviceList = [];
    if result is stream<utils:Device, error?> {
        if result is stream<utils:Device> {
            foreach var item in result {
                utils:Device device = {
                    price: item.price,
                    imageUrl: item.imageUrl,
                    name: item.name,
                    description: item.description,
                    id: item.id,
                    category: item.category,
                    promos: item.promos
                };
                deviceList.push(device);
            }
        }
    }
    return deviceList;
}

public function addDevice(string id, string name, string description, string category, string imageUrl, float price) returns string {

    map<json> device = {
        price: price,
        imageUrl: imageUrl,
        name: name,
        description: description,
        id: id,
        category: category,
        promos: []
    };
    mongodb:Error? result = checkpanic mongoClient->insert(device,"devicesTest1");
    if result is mongodb:Error {
        return "Failed";
    }
    return "Success";
}

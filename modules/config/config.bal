import ballerina/os;

public string dBConnectionUrl = check getValueFromEnvVariables("DB_CONNECTION_URL", "");
public string dbCluster = check getValueFromEnvVariables("DB_CLUSTER", "");
public string systemAppClientID = check getValueFromEnvVariables("CLIENT_ID", "");
public string systemAppClientSecret = check getValueFromEnvVariables("CLIENT_SECRET", "");
public string tokenEndpoint = check getValueFromEnvVariables("TOKEN_ENDPOINT", "");
public string scimEndpoint = check getValueFromEnvVariables("SCIM_ENDPOINT", "");
public string customerGroupId = "938a9653-e3d1-4a6c-9b72-78bc884ac6c3";

function getValueFromEnvVariables(string variable, string defaultValue) returns string {
    string value = os:getEnv(variable);
    return value != "" ? value : defaultValue;
}

import ballerina/os;

public configurable string dBConnectionUrl = check getValueFromEnvVariables("DB_CONNECTION_URL", "");
public configurable string dbCluster = check getValueFromEnvVariables("DB_CLUSTER", "");
public configurable string systemAppClientID = check getValueFromEnvVariables("CLIENT_ID", "");
public configurable string systemAppClientSecret = check getValueFromEnvVariables("CLIENT_SECRET", "");
public configurable string tokenEndpoint = check getValueFromEnvVariables("TOKEN_ENDPOINT", "");
public configurable string scimEndpoint = check getValueFromEnvVariables("SCIM_ENDPOINT", "");

function getValueFromEnvVariables(string variable, string defaultValue) returns string {
    string value = os:getEnv(variable);
    return value != "" ? value : defaultValue;
}

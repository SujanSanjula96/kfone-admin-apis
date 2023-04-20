import ballerina/os;

public string dBConnectionUrl = check getValueFromEnvVariables("DB_CONNECTION_URL", "");
public string dbCluster = check getValueFromEnvVariables("DB_CLUSTER", "");
public string systemAppClientID = check getValueFromEnvVariables("CLIENT_ID", "");
public string systemAppClientSecret = check getValueFromEnvVariables("CLIENT_SECRET", "");
public string tokenEndpoint = check getValueFromEnvVariables("TOKEN_ENDPOINT", "https://api.asgardeo.io/t/<orgName>/oauth2");
public string scimEndpoint = check getValueFromEnvVariables("SCIM_ENDPOINT", "https://api.asgardeo.io/t/<orgName>/scim2");
public string customerGroupId = check getValueFromEnvVariables("CUSTOMER_GROUP_ID", "");
public string customerGroupName = check getValueFromEnvVariables("CUSTOMER_GROUP_NAME", "");

function getValueFromEnvVariables(string variable, string defaultValue) returns string {
    string value = os:getEnv(variable);
    return value != "" ? value : defaultValue;
}

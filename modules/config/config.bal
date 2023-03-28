import ballerina/os;

public configurable string dBConnectionUrl = check getValueFromEnvVariables("DB_CONNECTION_URL", "");
public configurable string dbCluster = check getValueFromEnvVariables("DB_CLUSTER", "");

function getValueFromEnvVariables(string variable, string defaultValue) returns string {
    string value = os:getEnv(variable);
    return value != "" ? value : defaultValue;
}

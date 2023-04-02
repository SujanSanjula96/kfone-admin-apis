# kfone-admin-apis

This repo contains the backend implementation of the [Kfone Admin Portal](https://github.com/DonOmalVindula/kfone-admin-portal).

Backend Tech Stack - [Ballerina](https://ballerina.io/) and [MongoDB](https://www.mongodb.com/)

## Table of Contents
[[toc]]

## Configure and Run the service locally

### Prerequisites

1. [Install ballerina 2201.4.1](https://ballerina.io/learn/install-ballerina/installation-options/)
2. [Setup a cluster in MongoDB Atlas](https://www.mongodb.com/basics/mongodb-atlas-tutorial)
3. [Register a Management Application in Asgardeo](https://wso2.com/asgardeo/docs/apis/authentication/#register-a-management-app)
4. Create a user group in Asgardeo for the customers. (Eg: Customers)

### Build and Run

1. Clone the repository using following command.

```
git clone https://github.com/SujanSanjula96/kfone-admin-apis.git
```

2. Set the configurations as environmental variables. (Or update the https://github.com/SujanSanjula96/kfone-admin-apis/blob/main/modules/config/config.bal with default values. But remember to not to push your credentials to github)

| Variable | Description | Example |
| ---------------|-----------------|-----------------|
| `DB_CONNECTION_URL` |  MongoDB Connection URL  |  `mongodb+srv://<username>:<password>@<cluster>.abc.mongodb.net/test`  |
| `DB_CLUSTER` | MongoDB Cluster  | `cluster1`  |
| `CLIENT_ID`  | Client ID of the Management Application  | `abcdefghijKLM`   |
| `CLIENT_SECRET`  |  Client Secret of the Management Application  | `pqrsTUVxywz`   |
| `TOKEN_ENDPOINT`  | Asgardeo Token Endpoint   | `https://api.asgardeo.io/t/<orgName>/oauth2`   |
| `SCIM_ENDPOINT`  | Asgardeo SCIM Endpoint   | `https://api.asgardeo.io/t/<orgName>/scim2`   |
| `CUSTOMER_GROUP_ID`  | Customer user group ID   | `af4c7524-eb06-4d75-af47-b9e2a21863c5`   |

3. Build and run the service using following command.

```
bal run
```

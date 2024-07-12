# [Use Case] Movie Streaming Platform

The movie streaming platform allows users to register and subscribe to a package, providing them with unlimited access to movies and TV shows. Users can also receive notifications about new movie releases.

<img src=./resources/images/overview.png alt="Overview" width="70%">

## Deploying the system

### 1. Start all the Servers (MySQL, Oracle, Kafka, FTP, SFTP)

Run the following docker command to start MySQL, Oracle, Kafka, FTP, and SFTP servers.

```sh
docker compose up
```

### 2. Run the Ballerina project

Use this command to run the Ballerina project.

```
bal run
```

### 3. Run the file uploader

Use this command to upload a file to the SFTP server.

```
cd uploader
bal run file_uploader.bal
```

### 4. Interact with the Ballerina service

Use HTTP requests in the `send_request.http` file to call REST APIs in the service.  

## Database Integration

Database functionalities are demonstrated through three scenarios. The first scenario involves user registration and related operations, showing basic CRUD operations. The second scenario highlights database transactions by illustrating a user subscribing to a package. The last scenario demonstrates transaction rollbacks.

### Client Configurations

This section shows how to configure MySQL and Oracle database clients in Ballerina.

**MySQL Client**:

```ballerina
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

mysql:Client|sql:Error database = new (host, username, password, databaseName, port);
```

**OracleDB Client**:

```ballerina
import ballerinax/oracledb;
import ballerinax/oracledb.driver as _;

oracledb:Client|sql:Error database = check new (host, username, password, databaseName, port);
```

### 1. Basic Database Operations

Here, it demonstrates registering a user, retrieving user information, updating user details, and finally deleting the user. The implementation accesses a MySQL or Oracle database using credentials and performs CRUD operations on the database.

<img src=./resources/images/basic-crud.png alt="Basic Database Operations" width="40%">

### 2. Database Transactions

When a user subscribes to an OTT package, the process begins by adding a new record to the subscriptions table. Next, the user's record is updated with the newly assigned subscription ID. Finally, a new record is inserted into the payments table. All three steps occur within an atomic transaction, ensuring that if any step fails, the entire process is rolled back to its initial state.

<img src=./resources/images/db-transaction.png alt="Database Transactions" width="30%">

### 3. Database Transactions with Rollback

This scenario demonstrates how rollback works when a transaction fails. In the user subscription scenario, a new record is added to the subscriptions table, and the user's record is updated with the newly assigned subscription ID. Adding a new record into the payments table will fail due to an invalid value in the payment field, and then all previous steps will be rolled back to the initial state.

<img src=./resources/images/db-transaction-rollback.png alt="Database Transactions with Rollbacks" width="40%">

## FTP & Kafka Integration

To show the capabilities of Ballerina FTP and Kafka packages, a file (movie) is uploaded to an SFTP server using the FTP client.  A Ballerina FTP listener is configured to receive updates about new file uploads to the FTP server. When a new file is uploaded, it extracts details from the file and sends information about the movie release to a Kafka topic using a Kafka producer. Then a Kafka listener will then consume the messages from the topic and send emails to all users about the new releases.

<img src=./resources/images/ftp_kafka_integration.png alt="Kafka Integration" width="60%">

### Kafka Configurations

This section shows how to configure a Kafka producer and a Kafka listener in Ballerina.

**Kafka Producer**:

```ballerina
import ballerinax/kafka;

kafka:Producer producer = check new (kafka:DEFAULT_URL);
```

**Kafka Listener**:

```ballerina
import ballerinax/kafka;

listener kafka:Listener kafkaListener = new (kafka:DEFAULT_URL, {
    groupId: "new-releases-id",
    topics: "new-releases"
});
```

### FTP Configurations

This section shows how to configure an FTP client and service in Ballerina.

**FTP Client**:

```ballerina
import ballerina/ftp;

ftp:Client fileClient = check new ({
    host,
    port,
    auth: {
        credentials: {
            username,
            password
        }
    }
});
```

**FTP Listener**:

```ballerina
import ballerina/ftp;

ftp:Listener fileListener = check new ({
    host,
    port,
    auth: {
        credentials: {
            username,
            password
        }
    },
    fileNamePattern
});
```

### SFTP Configurations

This section shows how to configure an SFTP client and service in Ballerina.

**SFTP Client**:

```ballerina
import ballerina/ftp;

ftp:Client fileClient = check new ({
    protocol: ftp:SFTP,
    host,
    port,
    auth: {
        credentials: {
            username,
            password
        },
        privateKey: {
            path: privateKeyPath
        }
    }
});
```

**SFTP Listener**:

```ballerina
import ballerina/ftp;

ftp:Listener fileListener = check new ({
    protocol: ftp:SFTP,
    host,
    port,
    auth: {
        credentials: {
            username,
            password
        },
        privateKey: {
            path: privateKeyPath
        }
    },
    fileNamePattern
});
```

## REST APIs

```
POST /users - creates a user

GET /users - gets details of a user

PUT /users -  updates details of a user

DELETE /users - deletes a user

POST /users/subscription - user subscribes to a package
```

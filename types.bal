import ballerina/ftp;
import ballerinax/googleapis.gmail;

# Represents a user in media streaming platform.
#
# + id - id of the user
# + username - username of the user
# + email - email of the user
# + password - password of the user  
# + subscriptionId - subscription id of the user
public type User record {|
    string id?;
    string username;
    string email;
    string password;
    string subscriptionId?;
|};

# Represents a package details necessary for the users to get subscribed.
#
# + username - username of the user
# + password - password of the user
# + packageType - type of the package 
# + amount - tranasferred amount
public type Package record {|
    string username;
    string password;
    PackageType packageType;
    int amount;
|};

const map<decimal> pricingModel = {
    BASIC: 3.99,
    PREMIUM: 44.99
};

# Represents types of the packages available in the platform.
public enum PackageType {
    BASIC,
    PREMIUM
};

# Represents a movie in the platform.
#
# + title - title of the movie
# + year - year of the movie
# + director - director of the movie
public type Movie record {|
    string title;
    int year;
    string director;
|};

# Represents an email.
#
# + email - email address
public type Email record {|
    string email;
|};

public type DatabaseConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

public type SftpConfig record {|
    ftp:Protocol protocol;
    string host;
    int port;
    ftp:AuthConfiguration auth;
|};

public type SftpListenerConfig record {|
    ftp:Protocol protocol;
    string host;
    int port;
    string path = "/";
    ftp:AuthConfiguration auth;
    string fileNamePattern;
    decimal pollingInterval;
|};

public type GmailConfig record {|
    gmail:ConnectionConfig auth;
|};

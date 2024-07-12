import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable DatabaseConfig databaseConfig = ?;

service / on new http:Listener(8080) {
    final mysql:Client database;

    function init() returns error? {
        self.database = check new (...databaseConfig);
    }

    resource function post users(User user) returns error? {
        _ = check self.database->execute(`INSERT INTO users (username, password, email) 
                                         VALUES (${user.username}, ${user.password}, ${user.email})`);
    }

    resource function get users(string username, string password) returns User|error? {
        return self.database->queryRow(`SELECT * FROM users WHERE username = ${username} and password = ${password}`);
    }

    resource function put users(string username, string password, string newEmail) returns error? {
        _ = check self.database->execute(`Update users SET email = ${newEmail}
                                         WHERE username = ${username} and password = ${password}`);

    }

    resource function delete users(string username, string password) returns error? {
        _ = check self.database->execute(`DELETE from users WHERE username = ${username} and password = ${password}`);
    }

    resource function post users/subscription(Package package) returns error? {
        transaction {
            decimal price = pricingModel.get(package.packageType);
            User userResult = check self.database->queryRow(`SELECT * FROM users WHERE username = ${package.username} 
                                                            and password = ${package.password}`);

            _ = check self.database->execute(
                `INSERT INTO subscriptions (userId, packageName, startDate, endDate, price) VALUES 
                (${userResult.id}, ${package.packageType}, NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR), ${price})`);

            int subId = check self.database->queryRow(`SELECT id FROM subscriptions WHERE userId = ${userResult.id}`);

            _ = check self.database->execute(`UPDATE users SET subscriptionId = ${subId} WHERE id = ${userResult.id}`);

            _ = check self.database->execute(`INSERT INTO payments (userId, subscriptionId, transactionDate, amount)
                                             VALUES (${userResult.id}, ${subId} , NOW(), ${package.amount})`);
            check commit;
        }
    }
}

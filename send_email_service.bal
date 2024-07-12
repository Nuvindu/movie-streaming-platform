import ballerina/log;
import ballerina/sql;
import ballerinax/googleapis.gmail;
import ballerinax/kafka;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string kafkaGroupId = ?;
configurable string kafkaTopic = ?;

listener kafka:Listener kafkaListener = new (kafka:DEFAULT_URL, {
    groupId: kafkaGroupId,
    topics: kafkaTopic
});

service on kafkaListener {
    final gmail:Client|error gmail;
    final mysql:Client database;

    function init() returns error? {
        self.database = check new (...databaseConfig);
        self.gmail = trap new ({
            auth: {
                clientId,
                clientSecret,
                refreshToken
            }
        });
    }

    remote function onConsumerRecord(Movie[] movies) returns error? {
        string newReleases = string `New Releases: ${
            string:'join(", ", ...from Movie movie in movies
                select string `${movie.title} (${movie.year})`)}`;
        log:printInfo(newReleases);
        gmail:Client|error gmail = self.gmail;
        if gmail is error {
            log:printError("Error initializing gmail client: " + gmail.message());
            return;
        }
        stream<Email, sql:Error?> emails = self.database->query(`SELECT email FROM users`);
        check from Email email in emails
            do {
                error? send = self.sendMail(gmail, newReleases, email.email);
                if send is error {
                    log:printError("Error sending email to: " + email.email);
                }
            };
    }

    function sendMail(gmail:Client gmail, string body, string recipientEmail) returns error? {
        gmail:MessageRequest message = {
            to: [recipientEmail],
            subject: "New Movies Released",
            bodyInHtml: string `<html>
                                    <head>
                                        <title>New Releases</title>
                                        <body>${body}</body>
                                    </head>
                                </html>`
        };
        _ = check gmail->/users/me/messages/send.post(message);
    }
}

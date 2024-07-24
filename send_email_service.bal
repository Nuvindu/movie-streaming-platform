import ballerina/email;
import ballerina/log;
import ballerina/mime;
import ballerina/sql;
import ballerinax/kafka;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable string kafkaGroupId = ?;
configurable string kafkaTopic = ?;

listener kafka:Listener kafkaListener = new (kafka:DEFAULT_URL, {
    groupId: kafkaGroupId,
    topics: kafkaTopic
});

service on kafkaListener {
    final email:SmtpClient smtp;
    final mysql:Client database;

    function init() returns error? {
        self.database = check new (...databaseConfig);
        self.smtp = check new (
            host = host,
            username = username,
            password = password
        );
    }

    remote function onConsumerRecord(Movie[] movies) returns error? {
        string newReleases = string `New Releases: ${
            string:'join(", ", ...from Movie movie in movies
                    select string `${movie.title} (${movie.year})`)}`;
        log:printInfo(newReleases);
        stream<Email, sql:Error?> emails = self.database->query(`SELECT email FROM users`);
        check from Email email in emails
            do {
                check self.sendMail(self.smtp, newReleases, email.email);
            };
    }

    function sendMail(email:SmtpClient smtp, string body, string recipient) returns error? {
        email:Message message = {
            to: [recipient],
            subject: "New Movies Released",
            contentType: mime:TEXT_HTML,
            htmlBody: string `<html>
                                    <head>
                                        <title>New Releases</title>
                                        <body>${body}</body>
                                    </head>
                                </html>`
        };
        _ = check smtp->sendMessage(message);
    }
}

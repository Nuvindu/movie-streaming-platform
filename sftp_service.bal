import ballerina/ftp;
import ballerina/io;
import ballerina/http;
import ballerina/log;
import ballerinax/kafka;

configurable SftpListenerConfig sftpListenerConfig = ?;

listener ftp:Listener fileListener = check new (sftpListenerConfig);

service on fileListener {
    final http:Client clientEp;
    final kafka:Producer producer;

    function init() returns error? {
        self.clientEp = check new ("http://localhost:8080");
        self.producer = check new (kafka:DEFAULT_URL);
    }

    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        foreach ftp:FileInfo addedFile in event.addedFiles {
            log:printInfo(string `New movie has uploaded: ${addedFile.name}`);
            stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
            string metaContent = check from var chunk in fileStream select check string:fromBytes(chunk);
            string[] fileInfo = re `\n`.split(metaContent);
            return check self.producer->send({
                topic: kafkaTopic,
                value: {
                    title: fileInfo[0].trim(),
                    year: check int:fromString(fileInfo[1].trim()),
                    director: fileInfo[2].trim()
                }
            });
        }
    }
}

import ballerina/ftp;
import ballerina/io;

configurable SftpConfig sftpConfig = ?;

public type SftpConfig record {|
    ftp:Protocol protocol;
    string host;
    int port;
    ftp:AuthConfiguration auth;
|};

public function main() returns error? {
    ftp:Client fileUploader = check new (sftpConfig);
    string fileName = "furiosa";
    stream<io:Block, io:Error?> fileStream = check io:fileReadBlocksAsStream(string `../resources/movies/${fileName}.txt`, 1024);
    check fileUploader->put(string `/upload/${fileName}.txt`, fileStream);
    check fileStream.close();
}

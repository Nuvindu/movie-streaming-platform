import ballerina/ftp;
import ballerina/io;

configurable FtpConfig ftpConfig = ?;

public type FtpConfig record {|
    ftp:Protocol protocol;
    string host;
    int port;
    ftp:AuthConfiguration auth;
|};

public function main() returns error? {
    ftp:Client fileUploader = check new (ftpConfig);
    string fileName = "furiosa";
    stream<io:Block, io:Error?> fileStream = check io:fileReadBlocksAsStream(string `../resources/movies/${fileName}.txt`, 1024);
    check fileUploader->put(string `/upload/${fileName}.txt`, fileStream);
    check fileStream.close();
}

# Certificate Information

Certificate Information query using OpenSSL over remote ssh, assumes login with ssh-agent (or without passwd).

Retrieves SSL certificate common name (CN), serial and expiry date. Requests (curl) localhost URL and web server information.
Locates certificate file by matching the serial number and finds config files with the certificate path reference.

## Usage
```
$ ./crti.sh <hostname> [port] [crt path] [cfg path]
```
## Parameters
```
1:  Hostname (required)
2:  OpenSSL port (default: 443)
3:  Certificate search path (default openssl)
4:  Configuration search path (default: /etc)
```
## Examples

Retrieve certificate using default SSL port and config path
```
$ ./crti.sh myhost.mydomain.net
Certificate Information
        Hostname/port : myhost.mydomain.net port 443
        Serial number : 170CE7AA0953DC740983F70273B80A3C
        Valid until   : Jul 19 23:59:59 2024 GMT
        Certificate CN:  C = FI, ST = Uusimaa, O = MyDomain Inc, CN = myhost.mydomain.net
        Alternative CN:  DNS:myhost.mydomain.net, DNS:web.mydomain.net

Requesting localhost URL
        Server: Apache
        Location: https://web.mydomain.net

Searching '/etc' for configuration .......
/etc/pki/tls/web_mydomain_net.cer
        /etc/httpd/conf.d/ssl.conf
..done.
```
## Platform

Tested on GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)

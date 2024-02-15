# Certificate Information

Certificate Information query using OpenSSL over remote ssh, assumes login with ssh-agent (or without passwd).

Retrieves SSL certificate common name (CN), serial and expiry date.
Locates certificate file by verifying the serial number and reports config files with references.

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
Certificate Info : myhost.mydomain.net port 443
   Serial number : 170CE7AA0953DC740983F70273B80A3C
   Valid until   : Jul 17 23:59:59 2024 GMT
   Certificate CN: C = FI, ST = Uusimaa, O = MyDomain Inc, CN = myhost.mydomain.net

Searching /etc/pki/tls .....
/etc/pki/tls/certs/myhost_mydomain_net.cer
        /etc/httpd/conf.d/mydomain.conf
        /etc/httpd/conf.d/web_api.conf
....done
```
## Platform

Tested on GNU bash, version 4.2.46(2)-release (x86_64-redhat-linux-gnu)

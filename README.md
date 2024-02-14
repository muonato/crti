# Certificate Information

Certificate Information script queries host on remote ssh, assumes login with ssh-agent (or without passwd). Retrieves SSL certificate common name (CN), serial and expiry date. Locates certificate file by verifying the serial number and reports config files with references.

## Usage
```
crti.sh <hostname> [port] [crt path] [cfg path]
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
```

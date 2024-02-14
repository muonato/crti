# Certificate Information

Certificate Information script queries host on remote ssh, assumes login with ssh-agent (or without passwd). Retrieves SSL certificate common name (CN), serial and expiry date. Locates certificate file by verifying the serial number and reports config files with references.

## Usage
```
crti.sh <hostname> [port] [crt path] [cfg path]
```

#!/bin/bash
# muonato/crti @ GitHub 14-FEB-2024
#
# Certificate Information script queries host on remote
# ssh, assumes login with ssh-agent (or without passwd).
# Retrieves SSL certificate common name (CN), serial and
# expiry date. Locates certificate file by verifying the
# serial number and reports config files with references.
#
# Usage:
#       bash crti.sh <host> [port] [crt path] [cfg path]
#
# Parameters:
#       1:  Hostname (required)
#       2:  OpenSSL port (default: 443)
#       3:  Certificate search path (default openssl)
#       4:  Configuration search path (default: /etc)
#
# Examples:
#       1. Retrieve from SSL port 443, config path /etc:
#           $ ./crti.sh myhost.mydomain.net
#
#       2. Display certificate using specified SSL port:
#           $ ./crti.sh myhost.mydomain.net 55602

# Exit on error
set -e

# Usage help
if [[ -z $1 ]]; then
    echo -e "\nCertificate Information\n\t" \
    "Usage: $0 <hostname> [crt port] [crt path] [cfg path]\n\t Arguments:\n\t\t" \
    "1: hostname to query\n\t\t" \
    "2: (optional) port number to query for certificate (default: 443)\n\t\t" \
    "3: (optional) certificate search path (openssl default)\n\t\t" \
    "4: (optional) certificate config search path (default: '/etc')\n"
fi

: ${1?"ERROR: missing hostname"}

function sshc() {
    CMND=$1
    echo "" | echo $(ssh $HOST $CMND);
}
IFS=" "

# Color codes
HI="\033[1;36m"
LO="\033[0m"

# Args
HOST=$1
PORT=${2:-"443"}
LOCN=$3
CONF=${4:-"/etc"}

CERT=$(sshc "openssl s_client -connect localhost:$PORT 2>/dev/null|openssl x509 -text -noout -serial -enddate -subject")
SNUM=$(echo $CERT|grep -oP "(?<=serial=).*")
DATE=$(echo $CERT|grep -oP "(?<=notAfter=).*")
SUBJ=$(echo $CERT|grep -oP "(?<=subject=).*")

echo -e "Certificate Info : $HOST port $PORT"
echo -e "   Serial number : $HI$SNUM$LO"
echo -e "   Valid until   : $HI$DATE$LO"
echo -e "   Certificate CN: $HI$SUBJ$LO\n"

if [[ -z $LOCN ]]; then
    SSLV=$(sshc "openssl version -d")
    LOCN=$(echo $SSLV|grep -oP '(?<=").*(?=")')
fi

echo -n "Searching $LOCN "

CRT_FIND=$(sshc "sudo grep -rni 'BEGIN CERTIFICATE' $LOCN")
if [[ -z $CRT_FIND ]]; then
    echo -e "\nFound nothing."
fi

while read CRT_FILE; do
    CRT_PATH=$(echo $CRT_FILE|grep -oP "^[^:1:]+")
    if [[ -n $CRT_PATH ]]; then
        MATCH=$(sshc "sudo openssl x509 -noout -serial -in $CRT_PATH|grep -o '$SNUM'")
        if [[ -n $MATCH ]]; then
            echo -e "\n$HI$CRT_PATH$LO"
            CFG_FIND=$(sshc "sudo grep -rni '$CRT_PATH' $CONF")
            while read LINE; do
                echo -e "\t$LINE"|grep -oP "^[^:]+"
            done <<< $CFG_FIND
        fi
    fi
    echo -n "."
done <<< $CRT_FIND

echo -e "done\n"

if [[ -z $CFG_FIND ]]; then
    echo -e "Found no reference in $CONF\n"
fi

#!/bin/bash
# muonato/crti @ GitHub 16-FEB-2024
#
# Certificate Information query using OpenSSL connection,
# assuming login with ssh-agent (or without password).
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
# set -e

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

# parse certificate serial number, expiry date, subject and alternative subject names
CERT=$(sshc "openssl s_client -connect localhost:$PORT 2>/dev/null \
    |openssl x509 -text -noout -serial -enddate -subject")
SNUM=$(echo $CERT|grep -oP "(?<=serial=).*")
DATE=$(echo $CERT|grep -oP "(?<=notAfter=).*")
SUBJ=$(echo $CERT|grep -oP "(?<=subject=).*")
CSAN=$(echo $CERT|grep "DNS")

echo -e "Certificate Information " \
    "\n\tHostname/port : $HOST port $PORT" \
    "\n\tSerial number : $HI$SNUM$LO" \
    "\n\tValid until   : $HI$DATE$LO" \
    "\n\tCertificate CN: $HI$SUBJ$LO" \
    "\n\tAlternative CN: $HI$CSAN$LO\n"

if [[ -z $LOCN ]]; then
    SSLV=$(sshc "openssl version -d")
    LOCN=$(echo $SSLV|grep -oP '(?<=").*(?=")')
fi

echo "Requesting URL $HOST "
WWW_FIND=$(sshc "sudo curl -s -D- localhost")
if [[ -n $WWW_FIND ]]; then
    WWW_SERV=$(echo $WWW_FIND|grep -i "server")
    echo -e "\t$WWW_SERV"
    WWW_PAGE=$(echo $WWW_FIND|grep -i "location")
    echo -e "\t$WWW_PAGE\n"
else
    echo -e "done.\n"
fi

echo -n "Locating certificate and configuration "
CRT_FIND=$(sshc "sudo grep -rni -m 1 'BEGIN CERTIFICATE' $LOCN")
if [[ -n $CRT_FIND ]]; then
    while read CRT_FILE; do
        CRT_PATH=$(echo $CRT_FILE|grep -oP "^[^:]+")
        if [[ -n $CRT_PATH ]]; then
            MATCH=$(sshc "sudo openssl x509 -noout -serial -in $CRT_PATH 2>/dev/null|grep -o '$SNUM'")
            if [[ -n $MATCH ]]; then
                echo -e "\n\t$HI$CRT_PATH$LO"
                CFG_FIND=$(sshc "sudo grep -rni -m 1 '$CRT_PATH' $CONF")
                while read LINE; do
                    echo -e "\t\t$LINE"|grep -oP "^[^:]+"
                done <<< $CFG_FIND
            fi
            echo -n "."
        fi
    done <<< $CRT_FIND
fi
echo -e "done.\n"

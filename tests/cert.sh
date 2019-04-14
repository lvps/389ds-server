#!/bin/bash

HOSTNAME=${1:-ldaptest.example.local}
ID=${HOSTNAME//\./_}
export SAN=$HOSTNAME

if [[ ! -f noise.bin ]]; then
	 openssl rand -out noise.bin 4096
fi
if [[ -f ${ID}_cert.pem ]] && [[ -f ${ID}.key ]]; then
	echo "Reusing previous certificate"
else
	# https://security.stackexchange.com/a/86999
	openssl req -x509 -newkey rsa:2048 -sha256 -keyout ${ID}.key -out ${ID}_cert.pem -days 365 -nodes -extensions eku -config openssl.cnf -subj "/CN=${HOSTNAME}"
fi
# https://stackoverflow.com/a/4774063
HERE="$( cd "$(dirname "$0")" ; pwd -P )"
echo --- Add this to the playbook ---
echo "tls_cert_file: \"$HERE/${ID}_cert.pem\""
echo "tls_key_file: \"$HERE/${ID}.key\""
echo "tls_files_remote: false"
echo "tls_certificate_trusted: false"
echo --------------------------------

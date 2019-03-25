#!/bin/bash
if [[ ! -f noise.bin ]]; then
	 openssl rand -out noise.bin 4096
fi
if [[ -f test_cert.pem ]] && [[ -f test_key.pem ]]; then
	echo "Reusing previous certificate"
else
	openssl req -x509 -newkey rsa:2048 -sha256 -keyout test_key.pem -out test_cert.pem -days 365 -nodes -extensions eku -config openssl.cnf -subj "/CN=ldaptest.local"
fi
# https://stackoverflow.com/a/4774063
HERE="$( cd "$(dirname "$0")" ; pwd -P )"
echo Add these to the playbook:
echo "tls_cert_file: \"$HERE/test_cert.pem\","
echo "tls_key_file: \"$HERE/test_key.pem\","
echo "tls_files_remote: false"

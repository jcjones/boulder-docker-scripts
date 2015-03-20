#!/bin/sh

# Update from the Docker repo
docker pull quay.io/letsencrypt/boulder:latest
docker pull quay.io/jcjones/cfssl:latest

# Create keys
if [ ! -r /opt/cfssl/ca-key.pem ] ; then
  mkdir -p /opt/cfssl
  openssl genrsa -out /opt/cfssl/ca-key.pem 4096
  # Note to be valid we need to set extended parameters.
  openssl req -new -x509 -days 3650 -key /opt/cfssl/ca-key.pem \
      -subj '/C=UN/ST=Unknown/L=Unknown/CN=Test CA' -out /opt/cfssl/ca.pem
fi
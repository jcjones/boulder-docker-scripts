#!/bin/sh

# Must be run before Boulder.
# The CFSSL Docker image uses golang HEAD from 2015-02-17, which has various cryptographic improvements required by CFSSL.

sudo docker rm cfssl
sudo docker run --name cfssl -d \
    -p 22299:22299 \
    -v /opt/cfssl:/etc/cfssl:ro \
    quay.io/jcjones/cfssl serve -port=22299

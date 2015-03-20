#!/bin/sh

# Update from the Docker repo
docker pull quay.io/letsencrypt/boulder:latest
docker pull quay.io/jcjones/cfssl:latest

sudo docker stop cfssl
sudo docker stop boulder

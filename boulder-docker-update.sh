#!/bin/sh

# Update from the Docker repo
sudo docker pull quay.io/letsencrypt/boulder:latest
sudo docker pull quay.io/jcjones/cfssl:latest

sudo docker stop cfssl
sudo docker stop boulder

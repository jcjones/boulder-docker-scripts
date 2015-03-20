#!/bin/sh

# Pass a tag as arg1 to run that tag instead of latest.
TAG="latest"
if [ $# -gt 0 ] ; then
  TAG="$1"
fi

# Update from the Docker repo
sudo docker pull quay.io/letsencrypt/boulder:${TAG}
sudo docker pull quay.io/jcjones/cfssl:${TAG}

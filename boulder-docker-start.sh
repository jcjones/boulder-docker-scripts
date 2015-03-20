#!/bin/bash

# Pass a tag as arg1 to run that tag instead of latest.
TAG="latest"
if [ $# -gt 0 ] ; then
  TAG="$1"
fi

# If you want to set some env variables for your site, you can use
# a file called "config" to insert them into Docker.
#
# #config
# BASE_URL="https://example.com"
#
if [ -r config ] ; then
 CONFIG_PARAM="--env-file config"
fi

# The CFSSL Docker image uses golang HEAD from 2015-02-17, which has various cryptographic improvements required by CFSSL.
docker rm cfssl 2>&1 >/dev/null
docker run --name cfssl -d \
  -p 22299:22299 \
  -v /opt/cfssl:/etc/cfssl:ro \
  quay.io/jcjones/cfssl:${TAG} \
  serve -port=22299

# Start Boulder
docker rm boulder 2>&1 >/dev/null
docker run --name boulder -d \
  --link cfssl:cfssl \
  -p 4000:4000 \
  ${CONFIG_PARAM} \
  quay.io/letsencrypt/boulder:${TAG} \
  --cfssl "cfssl:22299" \
  monolithic

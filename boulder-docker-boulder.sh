#!/bin/sh

# Must be run after CFSSL

sudo docker rm boulder
sudo docker run --name boulder -d \
  --link cfssl:cfssl \
  -p 4000:4000 \
  quay.io/letsencrypt/boulder \
  --cfssl "cfssl:22299" \
  monolithic
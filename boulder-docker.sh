#!/bin/bash
CFSSL_TAG=latest
BOULDER_TAG=latest
ABSPATH=$(cd "$(dirname "$0")"; pwd)
CA_CNF=${ABSPATH}/ca.cnf
CFSSL_DIR=${ABSPATH}/cfssl
BOULDER_CONFIG=${ABSPATH}/boulder-config.json

confCheck() {
  # Load overrides from /etc/sysconfig/boulder if it exists
  if [ -r "/etc/sysconfig/boulder" ] ; then
    echo "[?] Loading overrides from /etc/sysconfig/boulder"
    source /etc/sysconfig/boulder
  else
    echo "[?] /etc/sysconfig/boulder does not exist; skipping"
  fi

  if [ -r "${ABSPATH}/boulder.config" ] ; then
    echo "[?] Loading overrides from ${ABSPATH}/boulder.config"
    source ${ABSPATH}/boulder.config
  else
    echo "[?] ${ABSPATH}/boulder.config does not exist; skipping"
  fi

  if ! [ -r ${BOULDER_CONFIG} ] ; then
    echo "[!] Could not find Boulder config at ${BOULDER_CONFIG}; does it exist?"
    exit 1
  fi
  if ! [ -d ${CFSSL_DIR} ] ; then
    echo "[!] Could not open CFSSL directory at ${CFSSL_DIR}; shall I create it and some keys? [Y/n]"
    read x
    if [ "${x}" == "y" ] || [ "${x}" == "Y" ] ; then
      mkdir -p ${CFSSL_DIR} || exit 2
      openssl req -newkey rsa:4096 -sha512 -days 9999 -x509 -nodes \
        -config ${CA_CNF} \
        -keyout ${CFSSL_DIR}/ca-key.pem \
        -out ${CFSSL_DIR}/ca.pem
    else
      exit 2
    fi
  fi
}

running() {
  if docker ps | grep ${1} 2>&1 >/dev/null; then
    return 0
  fi

  return 1
}

start() {
  local bConfDir=$(dirname ${BOULDER_CONFIG})
  local bConfFile=$(basename ${BOULDER_CONFIG})

  if ! running cfssl; then
    # Start CFSSL
    docker rm cfssl 2>&1 >/dev/null
    docker run --name cfssl -d \
      -p 22299:22299 \
      -v ${CFSSL_DIR}:/etc/cfssl:ro \
      quay.io/jcjones/cfssl:${CFSSL_TAG} \
      serve -port=22299
  else
    echo "[-] CFSSL already running..."
  fi

  if ! running boulder; then
    # Start Boulder
    docker rm boulder 2>&1 >/dev/null
    docker run --name boulder -d \
      --link cfssl:cfssl \
      -v ${bConfDir}:/boulder:ro \
      -p 4000:4000 \
      quay.io/letsencrypt/boulder:${BOULDER_TAG} \
      boulder --config /boulder/${bConfFile}
  else
    echo "[-] Boulder already running..."
  fi
}

status() {
  if running quay.io/letsencrypt/boulder; then
    echo "[-] Boulder is running"
  else
    echo "[-] Boulder is not running"
  fi

  if running quay.io/jcjones/cfssl; then
    echo "[-] CFSSL is running"
  else
    echo "[-] CFSSL is not running"
  fi

}

stop() {
  echo "[-] Stopping..."

  docker stop boulder
  docker stop cfssl
}

testOneshot() {
  echo "[-] Creating one-shot config and not publishing the TCP port..."
  echo "[-] Control c to exit"

  local bConfDir=$(dirname ${BOULDER_CONFIG})
  local bConfFile=$(basename ${BOULDER_CONFIG})

  docker run --rm=true \
    --link cfssl:cfssl -v \
    ${bConfDir}:/boulder:ro \
    quay.io/letsencrypt/boulder:${BOULDER_TAG} \
    boulder --config /boulder/${bConfFile}
}

update() {
  echo "[-] Updating..."

  docker pull quay.io/letsencrypt/boulder:${BOULDER_TAG}
  docker pull quay.io/jcjones/cfssl:${CFSSL_TAG}
}

case "$1" in
start)
  confCheck
  start
  ;;
stop)
  stop
  ;;
restart)
  confCheck
  stop
  start
  ;;
status)
  status
  ;;
update)
  confCheck
  update
  ;;
test)
  confCheck
  testOneshot
  ;;
*)
  echo $"Usage: $0 {start|stop|restart|status|update|test}"
  exit 1
  ;;
esac

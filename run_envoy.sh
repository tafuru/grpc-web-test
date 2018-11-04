#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0);pwd)

CONF_DIR=/etc/envoy/conf
ENVOY=/usr/local/bin/envoy
IMAGE=envoyproxy/envoy
IFACE="wlp3s0"
IP_ADDRESS=$(/sbin/ip -f inet -o addr show "${IFACE}" | cut -d\  -f 7 | cut -d/ -f 1)

docker run --rm --add-host=echo_server:$IP_ADDRESS -v $(pwd)/conf:$CONF_DIR -p 8080:8080 $IMAGE $ENVOY --v2-config-only -l info -c $CONF_DIR/envoy.yaml

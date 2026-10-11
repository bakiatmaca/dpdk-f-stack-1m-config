#!/bin/bash

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "[!] This script must be run as root (sudo)."
  exit 1
fi

echo "Run Multiple Instances Benchmark Tool"

# How many instances
COUNT=16

#target URL
BASE_TARGET_IP="192.168.1"
START_TARGET_HOST=60
START_TARGET_HOST_TWINS=80

TARGET_PORT="7051"

# Path benchmarking tool
TOOL_BIN="wrk"
# wrk configuration
THREADS=1
CONNECTIONS=31500
DURATION="180s"

NS_PREFIX="ns"

echo "[*] Launching $COUNT hardened $TOOL_BIN ..."
echo "[*] Target IP range base          : $BASE_TARGET_IP"
echo "[*] Starting host number          : $START_TARGET_HOST"
echo "[*] Starting host number (twins)  : $START_TARGET_HOST_TWINS"
echo "[*] Target Port                   : $TARGET_PORT"
echo

for ((i=0; i<COUNT; i++)); do

    NS="${NS_PREFIX}${i}"
    TARGET_URL="http://${BASE_TARGET_IP}.$((START_TARGET_HOST + i)):${TARGET_PORT}"
    TARGET_URL_TWINS="http://${BASE_TARGET_IP}.$((START_TARGET_HOST_TWINS + i)):${TARGET_PORT}"

    echo "    -> Starting $TOOL_BIN (netns = $NS, target = $TARGET_URL, twins = $TARGET_URL_TWINS) "
    ip netns exec ${NS} ${TOOL_BIN} -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency ${TARGET_URL}  &
    ip netns exec ${NS} ${TOOL_BIN} -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency ${TARGET_URL_TWINS}  &
    #echo "ip netns exec ${NS} ${TOOL_BIN} -t${THREADS} -c${CONNECTIONS} -d${DURATION} --latency ${TARGET_URL}"

done # for count
wait

echo
echo "Done"
echo

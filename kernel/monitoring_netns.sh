#!/bin/bash

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "[!] This script must be run as root (sudo)."
  exit 1
fi

echo "Monitoring NetNS State"

# How many instances
COUNT=16

PERIOD=2

CMD="ss -s"

NS_PREFIX="ns"

clear

while true; do
  for ((i=0; i<COUNT; i++)); do

    echo "[*] Monitoring $COUNT NetNS $CMD ..."
    echo

    NS="${NS_PREFIX}${i}"
    echo "[${NS}] -->"
    ip netns exec ${NS} ${CMD}
    echo

    sleep $PERIOD
    clear

  done # for count
done

echo
echo "Done"
echo

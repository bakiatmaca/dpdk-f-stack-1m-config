#!/bin/bash

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "[!] This script must be run as root (sudo)."
  exit 1
fi

echo "Isolated network interface (eth0, eth1, ...) for benchmark"

# How many namespaces, IPs, and wrk instances to create
COUNT=16

SYSCTL_CONFIG="./99-custom.conf"

BASE_IFACE="eth"

BASE_IP="192.168.1"

START_HOST=40

GATEWAY="192.168.1.1"

echo "[*] Launching $COUNT hardened network namespaces ..."
echo "[*] Using physical interface prefix   : $BASE_IFACE"
echo "[*] IP range base                     : $BASE_IP"
echo "[*] Starting host number              : $START_HOST"
echo "[*] Gateway                           : $GATEWAY"
echo "[*] Sysclt Config File                : $SYSCTL_CONFIG"
echo

for ((i=0; i<COUNT; i++)); do
    k=$((i))

    if (( i >= 9 )); then 9th if skipped 
        k=$((i + 1))
    fi

    NS="ns${i}"
    IF="${BASE_IFACE}${k}"
    IP="${BASE_IP}.$((START_HOST + i))/24"

    echo "-------------------------------------------"
    echo "creating: $NS -> $IF ($IP)"
    echo "-------------------------------------------"

    ip netns add "$NS"
    ip link set "$IF" netns "$NS"
    ip netns exec "$NS" ip addr add "$IP" dev "$IF"
#   ip netns exec "$NS" ip link set lo up
    ip netns exec "$NS" ip link set "$IF" up
#   ip netns exec "$NS" ip route add default via "$GATEWAY"

    echo "$NS created."

    echo "$NS setting sysctl params"
    ip netns exec "$NS" sysctl -p "$SYSCTL_CONFIG"
    echo "$NS has been configured"

    echo

done # for count

echo
echo "All Namespace are created"

echo
echo "using ns(s) interface"
echo -e "\t ex: sudo ip netns exec ns1 <command>\n"

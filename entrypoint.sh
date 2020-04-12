#!/bin/bash

# SIGTERM-handler
term_handler() {
    pkill -e hostapd
    pkill -e dhcpd
    pkill -e named
    ip link set ${INTERFACE} down
    sleep 1 # Let the apps close
    exit 143; # 128 + 15 -- SIGTERM
}

# Check if running in privileged mode
if [ ! -w "/sys" ] ; then
    echo "[Error] Not running in privileged mode."
    exit 1
fi

# Check environment variables
if [ ! "${INTERFACE}" ] ; then
    echo "[Error] An interface must be specified."
    exit 1
fi

# Configure interface
sed -i 's/interface=.*/interface='${INTERFACE}'/g' /etc/hostapd.conf

# Setup interface and restart DHCP service
ip link set ${INTERFACE} up
ip addr flush dev ${INTERFACE}
ip addr add 172.16.10.69/24 dev ${INTERFACE}

echo "Starting DHCP server .."
dhcpd ${INTERFACE}

echo "Starting ntp server .."
ntpd -4

echo "Starting HostAP daemon ..."
hostapd /etc/hostapd.conf &

# Wait for services to start
sleep 2

# Capture external docker signals
trap term_handler SIGINT SIGTERM SIGHUP

if pgrep -x hostapd >/dev/null
then
    echo "hostapd is running"
else
    echo "hostapd failed to start"
    term_handler
fi

wait $!

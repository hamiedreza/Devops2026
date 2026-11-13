#!/bin/bash
set -e

if [ -z "${RDP_PASSWORD:-}" ]; then
    echo "ERROR: Set RDP_PASSWORD"
    exit 1
fi

echo "trader:${RDP_PASSWORD}" | chpasswd

mkdir -p /run/dbus /run/xrdp
rm -f /run/dbus/pid
rm -f /run/xrdp/xrdp-sesman.pid

dbus-daemon --system --fork

/usr/sbin/xrdp-sesman
exec /usr/sbin/xrdp --nodaemon

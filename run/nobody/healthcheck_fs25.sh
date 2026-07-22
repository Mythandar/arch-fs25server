#!/usr/bin/env bash
set -euo pipefail

# Do not probe the RFB port with a bare TCP connection. TigerVNC counts those
# immediate disconnects as failed clients and eventually blacklists localhost,
# which also blocks websockify/noVNC from reaching Xvnc.
pgrep -x Xvnc >/dev/null
curl --fail --silent --show-error --output /dev/null \
  http://127.0.0.1:6080/vnc.html

case "${AUTOSTART_SERVER:-false}" in
  true|web_only)
    nc -z 127.0.0.1 7999
    ;;
esac

#!/usr/bin/env bash
set -euo pipefail

nc -z 127.0.0.1 5900
nc -z 127.0.0.1 6080

case "${AUTOSTART_SERVER:-false}" in
  true|web_only)
    host="${CONTAINER_IP:-127.0.0.1}"
    nc -z "$host" 7999
    ;;
esac

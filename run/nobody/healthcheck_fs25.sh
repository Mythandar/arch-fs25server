#!/usr/bin/env bash
set -euo pipefail

nc -z 127.0.0.1 5900
nc -z 127.0.0.1 6080

case "${AUTOSTART_SERVER:-false}" in
  true|web_only)
    nc -z 127.0.0.1 7999
    ;;
esac

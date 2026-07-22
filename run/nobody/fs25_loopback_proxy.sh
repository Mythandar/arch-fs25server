#!/usr/bin/env bash
set -euo pipefail

readonly port=7999

while true; do
  # Do not compete with GIANTS or another proxy if loopback already works.
  if nc -z 127.0.0.1 "$port" >/dev/null 2>&1; then
    sleep 5
    continue
  fi

  server_ip="$({
    ss -H -lnt4 "sport = :$port" 2>/dev/null || ss -H -lnt4 2>/dev/null
  } | awk -v port=":$port" '
    BEGIN { suffix = port "$" }
    $4 ~ suffix && $4 !~ /^127\./ && $4 !~ /^0\.0\.0\.0:/ {
      sub(suffix, "", $4)
      print $4
      exit
    }
  ')"

  if [ -z "$server_ip" ]; then
    sleep 2
    continue
  fi

  echo "INFO: GIANTS web server detected at ${server_ip}:${port}; enabling 127.0.0.1:${port}."
  exec socat \
    "TCP4-LISTEN:${port},bind=127.0.0.1,reuseaddr,fork" \
    "TCP4:${server_ip}:${port}"
done

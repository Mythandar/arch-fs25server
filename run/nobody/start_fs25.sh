#!/usr/bin/env bash

set -euo pipefail

export USER="${USER:-nobody}"

export WINEDEBUG=-all
export WINEPREFIX=~/.fs25server

# Keep the installed GIANTS listener aligned with the container's supervised
# localhost proxy and published port, while preserving existing credentials.
node /usr/local/bin/configure_web_config.mjs --port-only

/usr/local/bin/validate_fs25.sh runtime
bash /usr/local/bin/set-web-darkmode.sh

WEB_DATA="/opt/fs25/game/Farming Simulator 2025/web_data"
if [ -d "$WEB_DATA" ]; then
  (cd "$WEB_DATA" && bash /usr/local/bin/patch_web_ip.sh)
fi

server_exe="$HOME/.fs25server/drive_c/Program Files (x86)/Farming Simulator 2025/dedicatedServer.exe"

shutdown() {
  echo "INFO: Shutdown requested; asking Wine processes to exit."
  wineserver -k || true
}
trap shutdown TERM INT HUP

wine "$server_exe" &
wine_pid=$!

(
  for _ in $(seq 1 60); do
    if nc -z 127.0.0.1 7999; then
      /usr/local/bin/open_webinterface.sh >/dev/null 2>&1 || true
      exit 0
    fi
    sleep 1
  done
) &

wait "$wine_pid"

#!/usr/bin/env bash

set -euo pipefail

export USER="${USER:-nobody}"

web_config="$HOME/.fs25server/drive_c/Program Files (x86)/Farming Simulator 2025/dedicatedServer.xml"
server_config="$HOME/.fs25server/drive_c/users/$USER/Documents/My Games/FarmingSimulator2025/dedicated_server/dedicatedServerConfig.xml"

# Copy webserver config...

if [ -d "$(dirname "$web_config")" ]; then
  if [ ! -f "$web_config" ]; then
    cp "/home/nobody/.build/fs25/default_dedicatedServer.xml" "$web_config"
    echo "INFO: Created initial GIANTS web configuration."
  else
    echo "INFO: Preserving existing GIANTS web configuration."
  fi
else
  echo "ERROR: Game directory is unavailable at $(dirname "$web_config")." >&2
  exit 1
fi

# Copy server config

if [ -d "$(dirname "$(dirname "$server_config")")" ]; then
  mkdir -p "$(dirname "$server_config")"
  if [ ! -f "$server_config" ]; then
    cp "/home/nobody/.build/fs25/default_dedicatedServerConfig.xml" "$server_config"
    echo "INFO: Created initial dedicated server configuration."
  else
    echo "INFO: Preserving existing dedicated server configuration."
  fi
else
  echo "ERROR: FS25 configuration path is unavailable under the Wine prefix." >&2
  exit 1
fi

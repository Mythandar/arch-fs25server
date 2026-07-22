#!/usr/bin/env bash
set -euo pipefail

mode="${1:-runtime}"
prefix="${WINEPREFIX:-$HOME/.fs25server}"
game="/opt/fs25/game/Farming Simulator 2025"
config="/opt/fs25/config/FarmingSimulator2025"
exe="$game/dedicatedServer.exe"
server_xml="$game/dedicatedServer.xml"
runtime_config="$config/dedicated_server/dedicatedServerConfig.xml"

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[ -d "$prefix" ] || fail "Wine prefix is missing at $prefix. Persist the Binhex state directory by mounting host storage at /config; do not bind-mount /home/nobody/.fs25server."
[ -d "$game" ] || fail "Game directory is missing at $game. Check the /opt/fs25/game mount."
[ -f "$exe" ] || fail "Dedicated server executable is missing at $exe. Do not reinstall until the game mount and Wine symlink are verified."
[ -f "$server_xml" ] || fail "GIANTS web configuration is missing at $server_xml."
[ -r "$server_xml" ] || fail "GIANTS web configuration is not readable: $server_xml."

if ! grep -q '<initial_admin>' "$server_xml"; then
  fail "GIANTS web configuration does not contain initial_admin: $server_xml."
fi

if [ "$mode" = runtime ]; then
  [ -f "$runtime_config" ] || fail "Server configuration is missing at $runtime_config. Check the /opt/fs25/config mount and symlink."
fi

if ! find "$config" -maxdepth 1 -type f -name '*.dat' -print -quit 2>/dev/null | grep -q .; then
  printf 'WARNING: No licence .dat file was found directly under %s. Verify licensing in VNC before starting the game server.\n' "$config" >&2
fi

echo "INFO: FS25 ${mode} validation passed."

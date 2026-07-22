#!/usr/bin/env bash

set -euo pipefail

export WINEDLLOVERRIDES=mscoree=d
export WINEDEBUG=-all
export WINEPREFIX=~/.fs25server
export WINEARCH=win64
export USER="${USER:-nobody}"

# Debug info/warning/error color

NOCOLOR='\033[0;0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

# Create the prefix once and update it in place thereafter.  The prefix contains
# the GIANTS licence/registry state and must never be deleted during startup.
mkdir -p "$WINEPREFIX"

if [ ! -f "$WINEPREFIX/system.reg" ]; then
  echo -e "${GREEN}INFO: Initializing new Wine prefix at $WINEPREFIX.${NOCOLOR}"
  wineboot --init
else
  echo -e "${GREEN}INFO: Reusing persistent Wine prefix at $WINEPREFIX.${NOCOLOR}"
  wineboot --update
fi

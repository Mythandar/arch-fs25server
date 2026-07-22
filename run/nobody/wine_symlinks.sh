#!/usr/bin/env bash

set -euo pipefail

export USER="${USER:-nobody}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# Paths
GAME_DIR="/opt/fs25/game/Farming Simulator 2025"
CONFIG_DIR="/opt/fs25/config/FarmingSimulator2025"
WINE_GAME_DIR="$HOME/.fs25server/drive_c/Program Files (x86)/Farming Simulator 2025"
CONFIG_LINK_TARGET="$HOME/.fs25server/drive_c/users/$USER/Documents/My Games/FarmingSimulator2025"
LOG_DIR="$CONFIG_LINK_TARGET/dedicated_server/logs"

# ---------------------------------------------------------------------
# Ensure host game directory exists
# ---------------------------------------------------------------------
if [ ! -d "$GAME_DIR" ]; then
  echo -e "${RED}Warning: Game directory not found at $GAME_DIR${NOCOLOR}"
  echo "Creating directory..."
  mkdir -p "$GAME_DIR" || { echo -e "${RED}Failed to create $GAME_DIR${NOCOLOR}"; exit 1; }
  echo -e "${GREEN}Created directory: $GAME_DIR${NOCOLOR}"
fi

# ---------------------------------------------------------------------
# Ensure host config directory exists
# ---------------------------------------------------------------------
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "${RED}Warning: Config directory not found at $CONFIG_DIR${NOCOLOR}"
  echo "Creating directory..."
  mkdir -p "$CONFIG_DIR" || { echo -e "${RED}Failed to create $CONFIG_DIR${NOCOLOR}"; exit 1; }
  echo -e "${GREEN}Created directory: $CONFIG_DIR${NOCOLOR}"
fi

# ---------------------------------------------------------------------
# Symlink the host game path inside the Wine prefix
# ---------------------------------------------------------------------
if [ -L "$WINE_GAME_DIR" ] && [ "$(readlink "$WINE_GAME_DIR")" = "$GAME_DIR" ]; then
  echo -e "${GREEN}INFO: Game symlink is correct.${NOCOLOR}"
elif [ -L "$WINE_GAME_DIR" ]; then
  echo -e "${RED}Warning: Repairing stale game symlink at $WINE_GAME_DIR.${NOCOLOR}"
  rm "$WINE_GAME_DIR"
  ln -s "$GAME_DIR" "$WINE_GAME_DIR"
elif [ -e "$WINE_GAME_DIR" ]; then
  echo -e "${RED}Error: A real file or directory exists at $WINE_GAME_DIR; refusing to replace it. Move or migrate it before startup so the game mount can be linked safely.${NOCOLOR}"
  exit 1
else
  mkdir -p "$(dirname "$WINE_GAME_DIR")"
  ln -s "$GAME_DIR" "$WINE_GAME_DIR"
  echo -e "${GREEN}Symlink created: $WINE_GAME_DIR → $GAME_DIR${NOCOLOR}"
fi

# ---------------------------------------------------------------------
# Symlink the host config path inside the Wine prefix
# ---------------------------------------------------------------------
if [ -L "$CONFIG_LINK_TARGET" ] && [ "$(readlink "$CONFIG_LINK_TARGET")" = "$CONFIG_DIR" ]; then
  echo -e "${GREEN}INFO: Config symlink is correct.${NOCOLOR}"
elif [ -L "$CONFIG_LINK_TARGET" ]; then
  echo -e "${RED}Warning: Repairing stale config symlink at $CONFIG_LINK_TARGET.${NOCOLOR}"
  rm "$CONFIG_LINK_TARGET"
  ln -s "$CONFIG_DIR" "$CONFIG_LINK_TARGET"
elif [ -e "$CONFIG_LINK_TARGET" ]; then
  echo -e "${RED}Error: A real file or directory exists at $CONFIG_LINK_TARGET; refusing to replace it. Move or migrate it before startup so /opt/fs25/config remains authoritative.${NOCOLOR}"
  exit 1
else
  mkdir -p "$(dirname "$CONFIG_LINK_TARGET")"
  ln -s "$CONFIG_DIR" "$CONFIG_LINK_TARGET"
  echo -e "${GREEN}Symlink created: $CONFIG_LINK_TARGET → $CONFIG_DIR${NOCOLOR}"
fi

# ---------------------------------------------------------------------
# Ensure the log directory exists
# ---------------------------------------------------------------------
if [ -d "$LOG_DIR" ]; then
  echo -e "${GREEN}INFO: Log directories are in place!${NOCOLOR}"
else
  mkdir -p "$LOG_DIR"
  echo -e "${GREEN}Created log directory: $LOG_DIR${NOCOLOR}"
fi

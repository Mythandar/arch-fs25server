#!/bin/bash

WEBSERVER_PORT=7999

# Autostart
if [[ $AUTOSTART_SERVER = "true" ]] || [[ $AUTOSTART_SERVER = "web_only" ]]; then
  . /usr/local/bin/prepare_start.sh

  . /usr/local/bin/start_fs25.sh &

  # Wait for the webserver to start
  echo "Waiting for the webserver to start..."
  sleep 30

  # Safely get the webserver IP
  while read line ; do
    if nc -z $line $WEBSERVER_PORT; then
      DETECTED_WEBSERVER_IP="$line"
    fi
  done <<< "$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"

  # Check if an IP address was found
  if [ -n "$DETECTED_WEBSERVER_IP" ]; then
    echo "Webserver IP: $DETECTED_WEBSERVER_IP";
    export WEBSERVER_LISTENING_ON="$DETECTED_WEBSERVER_IP"
  else
    echo "No IP address found for the webserver."
    exit 1
  fi

  # The Supervisor-managed fs25-loopback program exclusively owns the
  # 127.0.0.1 proxy. Do not create additional socat listeners here.

  # Start Game Server
  if [[ $AUTOSTART_SERVER = "true" ]]; then
    node /usr/local/bin/start_game.mjs &
    #wine "/home/nobody/.fs25server/drive_c/Program Files (x86)/Farming Simulator 2025/x64/FarmingSimulator2025Game.exe" -name FarmingSimulator2025 -profile C:/users/nobody/Documents/My\ Games/FarmingSimulator2025 -server &
  fi;
fi;

# Keep the container running
cat

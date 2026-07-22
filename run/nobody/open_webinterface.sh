#!/usr/bin/env bash
set -euo pipefail

host="${CONTAINER_IP:-127.0.0.1}"
exec firefox "http://${host}:7999/index.html?lang=en&username=${WEB_USERNAME:-}&password=${WEB_PASSWORD:-}&login=Login"

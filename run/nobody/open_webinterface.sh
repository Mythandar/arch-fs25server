#!/usr/bin/env bash
set -euo pipefail

exec firefox "http://127.0.0.1:7999/index.html?lang=en&username=${WEB_USERNAME:-}&password=${WEB_PASSWORD:-}&login=Login"

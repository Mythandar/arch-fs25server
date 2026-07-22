#!/usr/bin/env bash

set -euo pipefail

export USER="${USER:-nobody}"

. /usr/local/bin/wine_init.sh

. /usr/local/bin/wine_symlinks.sh

. /usr/local/bin/copy_server_config.sh

/usr/local/bin/validate_fs25.sh runtime

. /usr/local/bin/cleanup_logs.sh

#!/usr/bin/env bash
# Install zoxide (smart cd).
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing zoxide..."
need_cmd curl

if have_cmd zoxide; then
  ok "zoxide already installed ($(command -v zoxide))"
  exit 0
fi

curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
ok "zoxide installed"

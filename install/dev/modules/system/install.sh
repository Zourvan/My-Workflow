#!/usr/bin/env bash
# Install base CLI packages (apt).
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing system packages..."
need_cmd sudo
need_cmd apt-get

sudo apt-get update
sudo apt-get install -y \
  zsh git curl wget fzf bat fd-find ripgrep lsof \
  build-essential python3 python3-pip \
  unzip ninja-build cmake gettext fonts-powerline eza btop

ok "System packages ready"

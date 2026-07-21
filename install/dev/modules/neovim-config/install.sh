#!/usr/bin/env bash
# Deploy Neovim config from repo nvim/ → ~/.config/nvim
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing Neovim IDE config..."

SRC="$REPO_ROOT/nvim"
[ -d "$SRC" ] || die "Missing repo config: $SRC"

DEST="$HOME/.config/nvim"
if [ -e "$DEST" ]; then
  BAK="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
  mv "$DEST" "$BAK"
  log "Backup: $BAK"
fi

mkdir -p "$(dirname "$DEST")"
copy_tree "$SRC" "$DEST"
ok "Neovim config deployed → $DEST"
log "Open nvim and run: :Lazy sync"

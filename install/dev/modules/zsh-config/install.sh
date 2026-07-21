#!/usr/bin/env bash
# Deploy Zsh config from repo zsh/.zshrc → ~/.zshrc
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing Zsh config..."

SRC="$REPO_ROOT/zsh/.zshrc"
[ -f "$SRC" ] || die "Missing repo config: $SRC"

DEST="$HOME/.zshrc"
backup_file "$DEST"
cp "$SRC" "$DEST"
ok "Zsh config deployed → $DEST"

# Ensure ~/.local/bin is on PATH (zoxide, etc.)
append_block_if_missing "MY-WORKFLOW PATH" "$DEST" '
# =========================================
# MY-WORKFLOW PATH
# =========================================
export PATH="$HOME/.local/bin:$PATH"
'

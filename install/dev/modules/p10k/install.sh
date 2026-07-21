#!/usr/bin/env bash
# Deploy Powerlevel10k config from repo p10k/.p10k.zsh → ~/.p10k.zsh
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing Powerlevel10k config..."

SRC="$REPO_ROOT/p10k/.p10k.zsh"
[ -f "$SRC" ] || die "Missing repo config: $SRC"

DEST="$HOME/.p10k.zsh"
backup_file "$DEST"
cp "$SRC" "$DEST"
ok "p10k config deployed → $DEST"

# Ensure ~/.zshrc sources p10k if present
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
append_block_if_missing "p10k.zsh" "$ZSHRC" '
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
'

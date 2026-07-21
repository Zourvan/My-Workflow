#!/usr/bin/env bash
# Install tmux + TPM + deploy repo Tmux/.tmux.conf
set -euo pipefail
# shellcheck source=../../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

log "Installing tmux..."
need_cmd sudo
need_cmd apt-get
need_cmd git

sudo apt-get update
sudo apt-get install -y tmux

SRC="$REPO_ROOT/Tmux/.tmux.conf"
[ -f "$SRC" ] || die "Missing repo config: $SRC"

DEST="$HOME/.tmux.conf"
backup_file "$DEST"
cp "$SRC" "$DEST"
ok "tmux config deployed → $DEST"

TPM_DIR="$HOME/.tmux/plugins/tpm"
clone_if_missing https://github.com/tmux-plugins/tpm "$TPM_DIR"
ok "tmux ready (inside tmux: prefix + I to install plugins)"

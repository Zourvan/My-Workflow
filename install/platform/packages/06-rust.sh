#!/usr/bin/env bash
# packages/06-rust.sh — Rust via official rustup installer.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="rust"
GI_PACKAGE_DESC="Rust toolchain (rustup.rs official)"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  if [[ ! -f /root/.cargo/bin/rustc ]]; then
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs \
      | env RUSTUP_HOME=/root/.rustup CARGO_HOME=/root/.cargo sh -s -- -y --default-toolchain stable
    gi_register_rollback "rm -rf /root/.rustup /root/.cargo"
  fi

  cat >/etc/profile.d/golden-image-rust.sh <<'EOF'
export RUSTUP_HOME=/root/.rustup
export CARGO_HOME=/root/.cargo
export PATH="$CARGO_HOME/bin:$PATH"
EOF

  # Symlink common binaries to /usr/local/bin
  for bin in rustc cargo rustup; do
    [[ -x "/root/.cargo/bin/${bin}" ]] && ln -sf "/root/.cargo/bin/${bin}" "/usr/local/bin/${bin}"
  done

  export PATH="/root/.cargo/bin:$PATH"
  GI_INSTALLED_VERSION="$(rustc --version 2>/dev/null || echo stable)"
}

gi_uninstall() {
  rm -rf /root/.rustup /root/.cargo /etc/profile.d/golden-image-rust.sh
  rm -f /usr/local/bin/rustc /usr/local/bin/cargo /usr/local/bin/rustup
}

gi_verify() {
  export PATH="/root/.cargo/bin:$PATH"
  gi_verify_cmd rustc
  gi_verify_cmd cargo
}

gi_package_main "${1:-install}"

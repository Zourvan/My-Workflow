#!/usr/bin/env bash
# packages/03-python.sh — Python 3.13 toolchain (uv, pipx, poetry, dev tools).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="python"
GI_PACKAGE_DESC="Python 3.13, uv, pipx, poetry, black, ruff, pytest, mypy"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install_python313() {
  # Prefer official deadsnake-free paths: apt on 26.04, else uv-managed CPython
  if apt-cache show python3.13 >/dev/null 2>&1; then
    gi_apt_install python3.13 python3.13-venv python3.13-dev
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 313 2>/dev/null || true
    gi_register_rollback "update-alternatives --remove python3 /usr/bin/python3.13 2>/dev/null || true"
    GI_INSTALLED_VERSION="python3.13 (apt)"
    return 0
  fi

  gi_info "python3.13 not in apt — installing via official uv Python builds"
  gi_ensure_uv
  uv python install 3.13 --default
  ln -sf "$(uv python find 3.13 2>/dev/null || echo /root/.local/share/uv/python/cpython-3.13*/bin/python3)" \
    /usr/local/bin/python3.13 2>/dev/null || true
  GI_INSTALLED_VERSION="python3.13 (uv)"
}

gi_install() {
  gi_apt_install python3 python3-venv python3-dev python3-pip build-essential \
    libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev

  gi_install_python313
  gi_ensure_uv
  gi_ensure_pipx

  export PIPX_DEFAULT_PYTHON="${PIPX_DEFAULT_PYTHON:-python3.13}"
  gi_have_cmd python3.13 && export PIPX_DEFAULT_PYTHON=python3.13

  pipx install poetry --force 2>/dev/null || pipx install poetry
  pipx install black --force 2>/dev/null || pipx install black
  pipx install ruff --force 2>/dev/null || pipx install ruff
  pipx install pytest --force 2>/dev/null || pipx install pytest
  pipx install mypy --force 2>/dev/null || pipx install mypy

  ln -sf /root/.local/bin/poetry /usr/local/bin/poetry 2>/dev/null || true
  ln -sf /root/.local/bin/black /usr/local/bin/black 2>/dev/null || true
  ln -sf /root/.local/bin/ruff /usr/local/bin/ruff 2>/dev/null || true
  ln -sf /root/.local/bin/pytest /usr/local/bin/pytest 2>/dev/null || true
  ln -sf /root/.local/bin/mypy /usr/local/bin/mypy 2>/dev/null || true

  pipx install virtualenv --force 2>/dev/null || pipx install virtualenv

  gi_register_rollback "pipx uninstall poetry black ruff pytest mypy virtualenv 2>/dev/null || true"
}

gi_uninstall() {
  pipx uninstall poetry 2>/dev/null || true
  pipx uninstall black 2>/dev/null || true
  pipx uninstall ruff 2>/dev/null || true
  pipx uninstall pytest 2>/dev/null || true
  pipx uninstall mypy 2>/dev/null || true
  pipx uninstall virtualenv 2>/dev/null || true
  rm -f /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/python3.13
}

gi_verify() {
  gi_verify_cmd python3
  gi_verify_cmd uv
  gi_verify_cmd pipx
  for c in poetry black ruff pytest mypy virtualenv; do
    gi_have_cmd "$c" || { gi_error "Missing: $c"; return 1; }
  done
  python3 --version | grep -qE '3\.(1[3-9]|[2-9][0-9])' \
    || gi_warn "Python 3.13+ not default — check alternatives/uv"
}

gi_package_main "${1:-install}"

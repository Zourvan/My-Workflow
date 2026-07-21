#!/usr/bin/env bash
# packages/05-go.sh — Go official tarball with SHA256 verification.
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="go"
GI_PACKAGE_DESC="Go programming language (go.dev official release)"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  local arch goarch version tarball url expected
  arch="$(gi_arch_map)"
  case "$arch" in
    amd64) goarch="linux-amd64" ;;
    arm64) goarch="linux-arm64" ;;
  esac

  version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1 | tr -d '[:space:]')"
  tarball="${version}.${goarch}.tar.gz"
  url="https://go.dev/dl/${tarball}"

  gi_download "$url" "${GI_TMPDIR}/${tarball}"

  # go.dev/dl/*.sha256 returns HTML — use dl.google.com or official JSON manifest
  if gi_have_cmd jq; then
    expected="$(curl -fsSL 'https://go.dev/dl/?mode=json' \
      | jq -r --arg f "$tarball" '.[0].files[] | select(.filename == $f) | .sha256')"
  elif gi_have_cmd python3; then
    expected="$(curl -fsSL 'https://go.dev/dl/?mode=json' | python3 -c "
import json, sys
tarball = sys.argv[1]
for f in json.load(sys.stdin)[0]['files']:
    if f['filename'] == tarball:
        print(f['sha256'])
        break
" "$tarball")"
  else
    # dl.google.com serves raw checksum (sometimes duplicated on one line)
    expected="$(curl -fsSL "https://dl.google.com/go/${tarball}.sha256" \
      | tr -cd '0-9a-f' | head -c 64)"
  fi

  [[ -n "$expected" && "${#expected}" -eq 64 ]] \
    || die "Could not fetch SHA256 for ${tarball}"

  gi_verify_sha256 "${GI_TMPDIR}/${tarball}" "$expected"

  rm -rf /usr/local/go
  tar -C /usr/local -xzf "${GI_TMPDIR}/${tarball}"
  gi_register_rollback "rm -rf /usr/local/go"

  gi_append_line_once /etc/profile.d/golden-image-go.sh "golden-image-go" \
    'export PATH=$PATH:/usr/local/go/bin'

  GI_INSTALLED_VERSION="$version"
}

gi_uninstall() {
  rm -rf /usr/local/go
  rm -f /etc/profile.d/golden-image-go.sh
}

gi_verify() {
  export PATH="$PATH:/usr/local/go/bin"
  gi_verify_cmd go
}

gi_package_main "${1:-install}"

#!/usr/bin/env bash
# packages/14-database.sh — database clients (PostgreSQL, Redis, MySQL).
set -Eeuo pipefail
GI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export GI_ROOT
GI_PACKAGE="database"
GI_PACKAGE_DESC="PostgreSQL, Redis, MySQL/MariaDB client tools"
# shellcheck source=../common.sh
source "${GI_ROOT}/common.sh"

gi_install() {
  # Official Ubuntu packages — client tools only (no server by default)
  gi_apt_install postgresql-client redis-tools mariadb-client sqlite3

  GI_INSTALLED_VERSION="db-clients"
}

gi_uninstall() {
  apt-get remove -y postgresql-client redis-tools mariadb-client sqlite3 2>/dev/null || true
}

gi_verify() {
  gi_verify_cmd psql
  gi_verify_cmd redis-cli
  gi_have_cmd mysql || gi_have_cmd mariadb || { gi_error "mysql/mariadb client missing"; return 1; }
  gi_verify_cmd sqlite3
}

gi_package_main "${1:-install}"

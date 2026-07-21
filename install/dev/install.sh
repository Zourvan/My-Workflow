#!/usr/bin/env bash
# Delegates to unified root installer (developer modules).
exec bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/install.sh" "$@"

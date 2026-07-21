#!/usr/bin/env bash
# Delegates to unified root installer (platform / Golden Image modules).
exec bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/install.sh" "$@"

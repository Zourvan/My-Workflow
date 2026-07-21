# Changelog

All notable changes to the Golden Image framework are documented here.

## [1.0.0] - 2026-07-21

### Added
- Modular package installer (`packages/00-system.sh` … `18-configs.sh`)
- Main orchestrator `install.sh` with `--only`, `--skip`, `--list`
- Rollback via `uninstall.sh` per package or `--all`
- Upgrade pass via `update.sh`
- Verification framework via `verify.sh`
- Shared library `common.sh` (logging, retry, GPG/checksum, idempotency)
- Structured logs under `/var/log/golden-image/`
- State markers under `/var/lib/golden-image/state/`
- Configuration templates in `configs/`
- Documentation in `docs/`

### Packages
- Base system CLI, locale, chrony, journald persistence
- Shell stack: zsh, Oh My Zsh, Powerlevel10k, zoxide, starship
- Python 3.13 toolchain (uv, pipx, poetry, black, ruff, pytest, mypy)
- Node.js LTS (NodeSource), Go, Rust
- Docker CE + Compose + Buildx + Dive + LazyDocker
- Kubernetes (kubectl, helm), Terraform, Ansible
- Cloud CLIs (AWS, Azure, Google Cloud)
- Security baseline (UFW, fail2ban, unattended-upgrades)
- Network tools + VPN (WireGuard, OpenVPN, Tailscale)
- Database clients, monitoring CLIs, Hugging Face CLI, TUI tools

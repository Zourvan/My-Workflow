# Golden Image — Enterprise DevOps / MLOps Platform

Part of **My-Workflow** unified installer. Platform modules live here; use the root installer to combine dev + platform services.

## Quick Start

```bash
cd ..   # My-Workflow root
./install.sh --golden          # full platform stack
./install.sh --devops          # DevOps subset
./install.sh --only gi-docker,gi-python
sudo ./verify.sh
```

Legacy path (symlink): `golden-image/` → `install/platform/`

## Features

| Feature | Description |
|---------|-------------|
| **Modular** | 19 independent package scripts under `packages/` |
| **Idempotent** | Skips already-installed components (override with `GI_FORCE_REINSTALL=1`) |
| **Logged** | Per-package logs in `/var/log/golden-image/` |
| **Verifiable** | `./verify.sh` checks binaries, versions, services |
| **Rollback** | `./uninstall.sh <package>` with rollback hooks |
| **Signed repos** | Docker, HashiCorp, NodeSource, Tailscale, Kubernetes — official GPG only |
| **No PPAs** | Vendor repositories and official release binaries only |

## Repository Layout

```text
golden-image/
├── install.sh          # Main installer
├── uninstall.sh        # Rollback / remove packages
├── update.sh           # Upgrade pass
├── verify.sh           # Verification framework
├── version.sh          # Show installed tool versions
├── common.sh           # Shared library
├── packages/           # Modular installers (00-system … 18-configs)
├── configs/            # git, zsh, tmux, ssh, vim, aliases
├── logs/               # Local cache (runtime logs → /var/log/golden-image)
├── cache/              # Download cache / temp extracts
└── docs/               # Guides
```

## Usage

### Full installation

```bash
sudo ./install.sh
```

### Selective installation

```bash
sudo ./install.sh --only system,shell,docker,python
sudo ./install.sh --skip ai,cloud,monitoring
sudo ./install.sh --list
```

### Target user (config deployment)

```bash
sudo GI_TARGET_USER=devops ./install.sh
```

### Reinstall a package

```bash
sudo GI_FORCE_REINSTALL=1 ./install.sh --only docker
```

### Verify

```bash
sudo ./verify.sh
sudo ./verify.sh --only docker,kubernetes,python
```

### Upgrade

```bash
sudo ./update.sh
sudo ./update.sh --only docker,python,kubernetes
```

### Uninstall / rollback

```bash
sudo ./uninstall.sh docker
sudo ./uninstall.sh terraform python
sudo ./uninstall.sh --all
```

## Packages

| ID | Module | Contents |
|----|--------|----------|
| `system` | 00-system | Base CLI, locale, chrony, journald, logrotate |
| `shell` | 01-shell | zsh, Oh My Zsh, p10k, zoxide, starship |
| `git` | 02-git | git, git-lfs, global gitconfig |
| `python` | 03-python | Python 3.13, uv, pipx, poetry, black, ruff, pytest, mypy |
| `node` | 04-node | Node.js 22 LTS (NodeSource) |
| `go` | 05-go | Go (official tarball + SHA256) |
| `rust` | 06-rust | Rust via rustup |
| `docker` | 07-docker | Docker CE, Compose, Buildx, Dive, LazyDocker |
| `kubernetes` | 08-kubernetes | kubectl, Helm |
| `terraform` | 09-terraform | HashiCorp Terraform |
| `ansible` | 10-ansible | Ansible Core |
| `cloud` | 11-cloud | AWS CLI, Azure CLI, Google Cloud SDK |
| `security` | 12-security | UFW, fail2ban, unattended-upgrades |
| `network` | 13-network | httpie, xh, grpcurl, doggo, WireGuard, OpenVPN, Tailscale |
| `database` | 14-database | psql, redis-cli, mysql/mariadb, sqlite3 |
| `monitoring` | 15-monitoring | promtool, amtool |
| `ai` | 16-ai | Hugging Face CLI |
| `tui` | 17-tui | LazyGit, LazyDocker, btop, dua |
| `configs` | 18-configs | Deploy shell/editor/SSH/tmux configs |

## Logging

| Path | Purpose |
|------|---------|
| `/var/log/golden-image/install.log` | Master log |
| `/var/log/golden-image/<package>.log` | Per-package log |
| `/var/lib/golden-image/state/` | Install state markers |
| `/var/lib/golden-image/rollback/` | Rollback scripts |

## Relationship to `setup/`

This repository also includes `setup/` — a **user-level** interactive installer for developer workstations (no root required for most steps).

| Use case | Tool |
|----------|------|
| Enterprise Golden Image / VM template | `golden-image/` (this) |
| Personal dev machine bootstrap | `setup/install.sh` |

## Documentation

- [Installation Guide](docs/INSTALL.md)
- [Upgrade Guide](docs/UPGRADE.md)
- [Uninstall Guide](docs/UNINSTALL.md)
- [Architecture](docs/ARCHITECTURE.md)

## Requirements

- Ubuntu Server 24.04+ / 26.04 LTS (amd64 or arm64)
- Root access (`sudo`)
- Outbound HTTPS (GitHub, vendor repos)
- ≥ 20 GB disk, ≥ 4 GB RAM recommended for full stack

## License

MIT — see [LICENSE](LICENSE)

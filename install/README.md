# My-Workflow Install Framework

Unified service catalog and execution engine for the whole project.

## Entry point

```bash
# From repository root
./install.sh
```

## Structure

| Path | Role |
|------|------|
| `catalog.sh` | All services (dev + platform) with presets |
| `engine.sh` | Interactive menus, CLI flags, execution |
| `dev/modules/` | Developer workstation installers |
| `platform/packages/` | DevOps / MLOps / Golden Image installers |
| `platform/configs/` | Templates deployed by platform |

## Service tiers

- **dev** — user-level modules (shell, neovim, dotfiles). May call `sudo` for apt/binaries.
- **platform** — system-level modules (Docker, K8s, Terraform). Require root.

## Add a new service

1. Add installer under `dev/modules/<id>/install.sh` or `platform/packages/NN-<id>.sh`
2. Register in `catalog.sh`
3. Run `./install.sh --only <id>`

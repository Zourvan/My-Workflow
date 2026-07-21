# Architecture

## Design principles

1. **Single responsibility** — each `packages/NN-name.sh` owns one domain.
2. **Shared library** — `common.sh` provides logging, apt helpers, GitHub downloads, state.
3. **Idempotency** — state file per package under `/var/lib/golden-image/state/`.
4. **Fail fast** — `set -Eeuo pipefail` and `trap ERR` in all scripts.
5. **Official sources only** — signed apt repos and verified release tarballs.

## Execution flow

```text
install.sh
    │
    ├─ source common.sh
    ├─ gi_require_root
    ├─ build package list (--only / --skip)
    │
    └─ for each package:
           packages/NN-name.sh install
               ├─ gi_package_init
               ├─ skip if state marker (unless FORCE)
               ├─ gi_install()
               ├─ gi_register_rollback() hooks
               └─ gi_mark_installed()
```

## Package script contract

Every package must define:

```bash
GI_PACKAGE="name"
GI_PACKAGE_DESC="description"
gi_install()   { ... }
gi_uninstall() { ... }
gi_verify()    { ... }
gi_package_main "${1:-install}"
```

Optional: `gi_upgrade()` — defaults to reinstall if absent.

## Logging model

```text
/var/log/golden-image/
├── install.log      # all packages
├── system.log
├── docker.log
└── ...
```

All log lines: `[ISO8601] [LEVEL] [package] message`

## Configuration deployment

`18-configs.sh` uses `gi_deploy_config()`:

| Source | Targets |
|--------|---------|
| `configs/zshrc` | `/etc/skel/.zshrc`, `/root/.zshrc`, `$HOME/.zshrc` |
| `configs/tmux.conf` | skel + root + target user |
| `configs/ssh_config` | `/etc/ssh/ssh_config.d/` + `~/.ssh/config` |

## Golden Image platforms

| Platform | Notes |
|----------|-------|
| VMware | Sysprep / cloud-init before capture |
| Proxmox | Convert to template after verify |
| Hyper-V | Check Integration Services |
| VirtualBox | Remove guest additions conflicts if any |
| Cloud | Use cloud-init + `GI_TARGET_USER` |
| Bare metal | Run after RAID/disk layout complete |

## Extending

Add `packages/19-custom.sh`:

```bash
GI_PACKAGE="custom"
GI_PACKAGE_DESC="My internal tools"
source "${GI_ROOT}/common.sh"
gi_install() { ... }
gi_uninstall() { ... }
gi_verify() { gi_verify_cmd mytool; }
gi_package_main "${1:-install}"
```

Register in `install.sh` → `GI_PACKAGE_ORDER` array.

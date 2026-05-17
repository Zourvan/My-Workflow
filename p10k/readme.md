# Powerlevel10k setup guide

This folder contains [`.p10k.zsh`](./.p10k.zsh): a **Powerlevel10k** prompt configuration for Zsh. It pairs with the Oh My Zsh setup in [`../zsh/.zshrc`](../zsh/.zshrc), which sets `ZSH_THEME="powerlevel10k/powerlevel10k"` and sources `~/.p10k.zsh` when that file exists.

---

## Quick start

| Step | What to do |
|------|------------|
| 1 | Install Zsh, Oh My Zsh, and Powerlevel10k (see [`../zsh/readme.md`](../zsh/readme.md)) |
| 2 | Install a **Nerd Font v3** terminal font |
| 3 | Copy or symlink `.p10k.zsh` to `~/.p10k.zsh` |
| 4 | Use the repo [`../zsh/.zshrc`](../zsh/.zshrc) (or ensure yours sources `~/.p10k.zsh`) |
| 5 | Restart the shell: `exec zsh` |

---

## Install this config

Copy or link the file into your home directory:

```bash
# From this repo (adjust the path if yours differs)
cp "/path/to/My Workflow/p10k/.p10k.zsh" ~/.p10k.zsh
```

Or symlink so updates in the repo apply automatically:

```bash
ln -sf "/path/to/My Workflow/p10k/.p10k.zsh" ~/.p10k.zsh
```

Reload after editing (no full restart required):

```bash
source ~/.p10k.zsh
```

Your `.zshrc` should load it near the end (as in this repo’s zsh config):

```zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

**Instant prompt:** [`../zsh/.zshrc`](../zsh/.zshrc) sources the p10k instant-prompt cache *before* Oh My Zsh. Keep heavy `echo` / `printf` out of `.zshrc` above that block, or instant prompt may warn or mis-render. This config sets `POWERLEVEL9K_INSTANT_PROMPT=quiet`.

---

## What this prompt looks like

Generated with `p10k configure` on **2026-04-30** (classic powerline style). Wizard choices baked into this file:

| Option | Value |
|--------|--------|
| Style | Classic powerline |
| Font / icons | **Nerd Font v3** + powerline glyphs |
| Icon size | Small |
| Character set | Unicode |
| Color palette | Darkest |
| Separators | Angled, sharp heads/tails |
| Lines | **2** (multiline) |
| Frame | None (solid segments) |
| Density | Sparse, many icons, concise |
| Time | 24h (`%H:%M:%S`) |
| Transient prompt | **always** (minimal prompt after you press Enter) |
| Instant prompt | **quiet** |

**Line 1 (left):** OS icon → `user@host` → directory → Git status  
**Line 2 (left):** Prompt character (`❯` / `❮` in vi modes; green on success, red on error)

**Line 1 (right):** Exit status, command duration (≥3s), background jobs, tool/env segments (asdf, Python, Node, cloud, k8s, etc.), clock  
**Line 2 (right):** (newline only; optional segments like `ip` stay commented out)

A horizontal `─` filler connects left and right on the first line. An extra blank line is added before each prompt (`POWERLEVEL9K_PROMPT_ADD_NEWLINE=true`).

---

## Requirements

| Requirement | Why |
|-------------|-----|
| **Zsh ≥ 5.1** | Enforced at top of `.p10k.zsh` |
| **Powerlevel10k** | Oh My Zsh theme; install per [`../zsh/readme.md`](../zsh/readme.md) §3 |
| **Nerd Font v3** | `POWERLEVEL9K_MODE=nerdfont-v3` — without it, icons show as missing glyphs |
| **`~/.p10k.zsh`** | Default path sourced by `.zshrc` |

### Terminal font

Set your terminal’s font to a **Nerd Font** build (e.g. MesloLGS NF, JetBrainsMono Nerd Font, FiraCode Nerd Font). Powerlevel10k can print a font install hint on first run; you can also run:

```bash
p10k configure
```

and pick the font step, or follow [Powerlevel10k font docs](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k).

---

## Active prompt segments

### Left prompt (`POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`)

| Segment | Shows |
|---------|--------|
| `os_icon` | OS identifier |
| `context` | `user@hostname` (root highlighted) |
| `dir` | Current path (smart shortening) |
| `vcs` | Git branch/status (via custom formatter + gitstatus) |
| `newline` | Line break |
| `prompt_char` | Input prompt symbol |

### Right prompt (`POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS`)

Enabled segments include: `status`, `command_execution_time`, `background_jobs`, `direnv`, `asdf`, `virtualenv`, `anaconda`, `pyenv`, `goenv`, `nodenv`, `nvm`, `nodeenv`, `rbenv`, `rvm`, `fvm`, `luaenv`, `jenv`, `plenv`, `perlbrew`, `phpenv`, `scalaenv`, `haskell_stack`, `kubecontext`, `terraform`, `aws`, `aws_eb_env`, `azure`, `gcloud`, `google_app_cred`, `toolbox`, `nordvpn`, file-manager shells (`ranger`, `yazi`, `nnn`, `lf`, `xplr`), `vim_shell`, `midnight_commander`, `nix_shell`, `chezmoi_shell`, `todo`, `timewarrior`, `taskwarrior`, `per_directory_history`, `time`.

Many version segments are **hidden unless relevant** (e.g. kubecontext only when you run `kubectl`, `helm`, etc.). Commented lines in `.p10k.zsh` (e.g. `node_version`, `rust_version`, `disk_usage`) are available if you uncomment them.

---

## Notable settings

| Setting | Value | Effect |
|---------|--------|--------|
| `POWERLEVEL9K_BACKGROUND` | `234` | Dark segment background |
| `POWERLEVEL9K_DIR_MAX_LENGTH` | `80` | Path shortening threshold |
| `POWERLEVEL9K_SHORTEN_STRATEGY` | `truncate_to_unique` | Shorten middle path segments |
| `POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD` | `3` | Show duration only if command took ≥3 seconds |
| `POWERLEVEL9K_TIME_FORMAT` | `%D{%H:%M:%S}` | 24-hour clock with seconds |
| `POWERLEVEL9K_TRANSIENT_PROMPT` | `always` | Compact prompt after accepting a line |
| `POWERLEVEL9K_INSTANT_PROMPT` | `quiet` | Fast startup; suppress init warnings |
| `POWERLEVEL9K_DISABLE_HOT_RELOAD` | `true` | Slightly faster prompt; edit file + `source` to apply |

Git uses a custom `my_git_formatter` with **concise** status (staged/unstaged/untracked counts, ahead/behind). `POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true` keeps formatting in this file.

---

## Customize

### Edit by hand

Open `~/.p10k.zsh` (or the repo copy), change `POWERLEVEL9K_*` variables, then:

```bash
source ~/.p10k.zsh
```

Segment names and options are documented in-file. For help on one segment:

```bash
p10k help segment dir
```

### Re-run the wizard

This overwrites `~/.p10k.zsh` (or the path in `POWERLEVEL9K_CONFIG_FILE`):

```bash
p10k configure
```

To regenerate from scratch but keep this repo as source of truth, copy your changes back into `p10k/.p10k.zsh` after configuring, or symlink `~/.p10k.zsh` to the repo file.

### Add/remove right-prompt segments

Edit the `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=( ... )` array near the top of `.p10k.zsh`. Comment out tools you do not use (e.g. `aws`, `gcloud`) for a cleaner prompt.

### Transient prompt

- `off` — full prompt stays after Enter  
- `always` — trim prompt after Enter (**current**)  
- `same-dir` — trim except right after `cd`

Change `POWERLEVEL9K_TRANSIENT_PROMPT` near the end of the file.

---

## Troubleshooting

| Problem | What to try |
|---------|-------------|
| Broken / empty icons | Install and select a **Nerd Font v3** in the terminal |
| Prompt unchanged after edit | `source ~/.p10k.zsh` or `exec zsh` |
| Instant prompt warning | Move `echo` / slow commands below instant-prompt block in `.zshrc`, or set `POWERLEVEL9K_INSTANT_PROMPT=off` |
| Git segment slow or missing | Ensure [gitstatus](https://github.com/romkatv/gitstatus) is bundled with Powerlevel10k (default with theme) |
| `p10k: command not found` | Install Powerlevel10k theme; open a new shell with `ZSH_THEME=powerlevel10k/powerlevel10k` |
| Wizard overwrote config | Restore from this repo: `cp .../p10k/.p10k.zsh ~/.p10k.zsh` |

---

## Related files

| File | Role |
|------|------|
| [`../zsh/.zshrc`](../zsh/.zshrc) | Oh My Zsh, instant prompt hook, `source ~/.p10k.zsh` |
| [`../zsh/readme.md`](../zsh/readme.md) | Full shell install and plugin list |
| [Powerlevel10k repo](https://github.com/romkatv/powerlevel10k) | Upstream theme and documentation |

---

## File reference

| File | Purpose |
|------|---------|
| [`.p10k.zsh`](./.p10k.zsh) | All `POWERLEVEL9K_*` options, segment layout, colors, and git formatter |

The config is large (~1700 lines) because each segment has its own color, icon, and behavior block. Most day-to-day changes only require the two `*_PROMPT_ELEMENTS` arrays and a handful of globals at the top.

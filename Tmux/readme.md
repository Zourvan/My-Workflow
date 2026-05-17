# Tmux setup guide

This folder contains [`.tmux.conf`](./.tmux.conf): a Catppuccin-themed tmux setup with **TPM** (Tmux Plugin Manager), sensible defaults, pane tools, Vim-style navigation, and session restore.

---

## Quick start

| Step | What to do |
|------|------------|
| 1 | Install tmux (see below) |
| 2 | Copy or symlink `.tmux.conf` to `~/.tmux.conf` |
| 3 | Install TPM (clone into `~/.tmux/plugins/tpm`) |
| 4 | Start tmux and press **Prefix + I** to install plugins |

---

## Install tmux

### Linux (Debian / Ubuntu)

```bash
sudo apt update
sudo apt install -y tmux
tmux -V
```

### Linux (Fedora / RHEL)

```bash
sudo dnf install -y tmux
tmux -V
```

### macOS

```bash
brew install tmux
tmux -V
```

### Windows

Native Windows tmux is limited. Use **WSL2** (recommended) or Git Bash with a Linux environment:

```powershell
wsl --install
```

Inside WSL, use the Ubuntu steps above, then use tmux from your WSL terminal.

---

## Install this config

Copy or link the config into your home directory:

```bash
# From this repo (adjust the path if yours differs)
cp "/path/to/My Workflow/Tmux/.tmux.conf" ~/.tmux.conf
```

Or symlink so updates in the repo apply automatically:

```bash
ln -sf "/path/to/My Workflow/Tmux/.tmux.conf" ~/.tmux.conf
```

Reload after changes:

```bash
tmux source-file ~/.tmux.conf
```

Or from inside tmux: **Prefix** then **:** → type `source-file ~/.tmux.conf` → Enter.

---

## Tmux Plugin Manager (TPM)

TPM installs and updates plugins listed in `.tmux.conf`.

### One-time TPM install

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Your config already ends with:

```tmux
run '~/.tmux/plugins/tpm/tpm'
```

Do not move that line above the `@plugin` entries.

### Plugins in this config

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager |
| `catppuccin/tmux` | Catppuccin (mocha) theme and status bar |
| `tmux-plugins/tmux-sensible` | Safer defaults |
| `tmux-plugins/tmux-resurrect` | Save / restore sessions |
| `tmux-plugins/tmux-continuum` | Auto-save / restore (works with resurrect) |
| `tmux-plugins/tmux-yank` | Copy to system clipboard |
| `tmux-plugins/tmux-open` | Open paths / URLs from pane text |
| `tmux-plugins/tmux-pain-control` | Extra pane split / resize keys |
| `tmux-plugins/tmux-copycat` | Search pane text (like copycat) |
| `tmux-plugins/tmux-prefix-highlight` | Prefix indicator in status bar |
| `tmux-plugins/tmux-cpu` | CPU / RAM in status bar |
| `tmux-plugins/tmux-sidebar` | File tree sidebar |
| `christoomey/vim-tmux-navigator` | Move between Neovim and tmux panes |

---

## Install plugins with the keyboard (TPM)

**Prefix** in this config is **Ctrl + Space** (not the default Ctrl+b).

| Action | Keys | When to use |
|--------|------|-------------|
| **Install** plugins | **Prefix** → **I** (capital i) | First time after TPM clone, or after adding a new `@plugin` line |
| **Update** plugins | **Prefix** → **u** | Pull latest plugin versions |
| **Uninstall** removed plugins | **Prefix** → **Alt** + **u** | After deleting a `@plugin` line from `.tmux.conf` |

### First-time plugin install (step by step)

1. Ensure `~/.tmux.conf` is in place and TPM is cloned (see above).
2. Start tmux: `tmux`
3. Hold **Ctrl** and press **Space** (that is Prefix).
4. Press **Shift + I** (capital **I**).
5. Wait until TPM finishes in the status line or a brief message appears.
6. Optional: quit and restart tmux so every plugin loads cleanly: **Prefix** → **:** → `kill-server` → Enter, then run `tmux` again.

If **Prefix + I** does nothing, check that `~/.tmux/plugins/tpm` exists and that `run '~/.tmux/plugins/tpm/tpm'` is still the **last** line in `.tmux.conf`.

---

## Prefix and basics

| Concept | This config |
|---------|-------------|
| **Prefix** | **Ctrl + Space** |
| **Command prompt** | **Prefix** → **:** |
| **Detach** (leave tmux running) | **Prefix** → **d** |
| **Scroll / copy mode** | **Prefix** → **[** → arrows / PgUp / PgDn → **q** to exit |
| **Mouse** | Enabled (click panes, resize, scroll) |

The status bar shows a red **PREFIX** hint while Prefix is held.

---

## Keyboard reference (this repo + plugins)

### Panes and windows (custom + pain-control)

| Keys | Action |
|------|--------|
| **Prefix** → **\|** | Split pane **horizontally** (side by side) |
| **Prefix** → **+** | Split pane **vertically** (stacked) |
| **Prefix** → **p** | Select pane **up** |
| **Prefix** → **-** | Split vertical (pain-control; same idea as **+** if both bound) |
| **Prefix** → **h** / **j** / **k** / **l** | Resize pane left / down / up / right |
| **Prefix** → **H** / **J** / **K** / **L** | Select pane left / down / up / right |
| **Prefix** → **x** | Kill current pane (confirm) |
| **Prefix** → **z** | Zoom pane (toggle full pane) |
| **Prefix** → **c** | New window |
| **Prefix** → **n** / **p** | Next / previous window |
| **Prefix** → **&** | Kill window |
| **Prefix** → **,** | Rename window |

### Vim + tmux (vim-tmux-navigator)

Use **without** Prefix when Neovim (or Vim) is focused and `plug#tmux` / equivalent is set up in your editor:

| Keys | Action |
|------|--------|
| **Ctrl + h** | Left pane |
| **Ctrl + j** | Down pane |
| **Ctrl + k** | Up pane |
| **Ctrl + l** | Right pane |

Same keys move between tmux panes when the editor is not in the way. Install the matching Vim/Neovim plugin from the [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) README.

### Copy and search

| Keys | Action |
|------|--------|
| **Prefix** → **y** | Copy selection (tmux-yank; may need `xclip` / `wl-copy` on Linux) |
| **Prefix** → **/** | Search down in pane (copycat) |
| **Prefix** → **?** | Search up in pane (copycat) |
| **Prefix** → **]** | Paste last buffer |

### Open files / URLs (tmux-open)

| Keys | Action |
|------|--------|
| **Prefix** → **o** | Open file path under cursor (default app) |
| **Prefix** → **Ctrl + o** | Open in `$EDITOR` |
| **Prefix** → **g** | Go to file (same family as open) |

### Session save / restore

| Keys | Action |
|------|--------|
| **Prefix** → **Ctrl + s** | Save session (resurrect) |
| **Prefix** → **Ctrl + r** | Restore session (resurrect) |

`tmux-continuum` can auto-save on an interval (see plugin docs). Restored sessions appear after restart if resurrect data exists.

### Sidebar (tmux-sidebar)

| Keys | Action |
|------|--------|
| **Prefix** → **Tab** | Toggle file tree sidebar |
| **Prefix** → **Backspace** | Kill sidebar |

### TPM maintenance

| Keys | Action |
|------|--------|
| **Prefix** → **I** | Install plugins |
| **Prefix** → **u** | Update plugins |
| **Prefix** → **Alt + u** | Remove unused plugins |

---

## Status bar

| Area | Content |
|------|---------|
| Left | Session name; red **PREFIX** when active |
| Right | CPU %, RAM %, time (`HH:MM`) |

Theme: **Catppuccin Mocha** (`@catppuccin_flavour mocha`).

---

## Useful daily workflow

1. **New project session**  
   `tmux new -s myapp`  
   Detach with **Prefix + d**; reattach with `tmux attach -t myapp`.

2. **List sessions**  
   `tmux ls`

3. **After editing `.tmux.conf`**  
   `tmux source-file ~/.tmux.conf`  
   If you added a plugin: **Prefix + I**.

4. **True color / Neovim**  
   Config sets `default-terminal` to `tmux-256color` and RGB overrides for common terminals. In Neovim, use a colorscheme that supports truecolor in tmux.

5. **Clipboard on Linux (for tmux-yank)**  
   ```bash
   sudo apt install -y xclip    # X11
   # or
   sudo apt install -y wl-clipboard   # Wayland
   ```

6. **Prefix feels wrong in a terminal**  
   Some terminals steal **Ctrl + Space**. Change prefix in `.tmux.conf` (e.g. to `C-a`) and reload, or fix the terminal shortcut.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `command not found: tmux` | Install tmux in WSL/Linux/macOS (see above) |
| Plugins not loading | Clone TPM; run **Prefix + I**; keep `run ... tpm` at bottom of config |
| Garbled colors | Use `tmux-256color`; set terminal to truecolor in your emulator |
| **Prefix + I** no output | Run `ls ~/.tmux/plugins/tpm` — folder must exist |
| Duplicate `tmux-cpu` in config | Harmless; one entry is enough (you can remove the duplicate line in `.tmux.conf`) |
| Vim keys jump panes in insert mode | Configure vim-tmux-navigator in Neovim per upstream docs |

---

## File layout

```text
Tmux/
├── .tmux.conf    # Main config (copy to ~/.tmux.conf)
└── readme.md     # This guide
```

After setup, TPM and plugins live under:

```text
~/.tmux/plugins/
```

---

## Links

- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Catppuccin for tmux](https://github.com/catppuccin/tmux)
- [tmux cheatsheet](https://tmuxcheatsheet.com/)

# My Workflow — terminal dev environment

Dotfiles and automation for a **terminal-first** development setup: Zsh with Oh My Zsh and Powerlevel10k, Neovim as the editor, and Tmux for persistent sessions.

**One project, one installer** — pick services interactively or via CLI:

```bash
git clone <repository>
cd My-Workflow
./install.sh                    # interactive menu
```

| Mode | Command | When to use |
|------|---------|-------------|
| **Interactive** | `./install.sh` | Choose profile or custom services |
| **Developer** | `./install.sh --dev` | Shell + editor + CLI tools |
| **DevOps lab** | `./install.sh --devops` | Docker, K8s, Terraform, Ansible |
| **MLOps lab** | `./install.sh --mlops` | Python, Docker, AI, cloud CLIs |
| **Golden Image** | `./install.sh --golden` | Full platform stack (VM templates) |
| **Cherry-pick** | `./install.sh --only neovim,gi-docker` | Install only what you need |

Everything is versioned here; installers deploy configs from this repo (not embedded copies).

**Best on:** Linux, macOS, or **WSL2** on Windows. Native Windows terminals can use Neovim from `%LOCALAPPDATA%\nvim\`; Zsh/Tmux are intended for Unix-like environments.

---

## What you get

| Layer | Config | Highlights |
|-------|--------|------------|
| **Shell** | [`zsh/.zshrc`](zsh/.zshrc) | Oh My Zsh, autosuggestions, syntax highlighting, fzf, zoxide, eza, lazygit, Superfile |
| **Prompt** | [`p10k/.p10k.zsh`](p10k/.p10k.zsh) | Powerlevel10k (classic powerline, Nerd Font, transient prompt) |
| **Editor** | [`nvim/`](nvim/) | lazy.nvim, Tokyo Night, nvim-tree, Telescope, Treesitter, ToggleTerm, Lualine |
| **Multiplexer** | [`Tmux/.tmux.conf`](Tmux/.tmux.conf) | Catppuccin, TPM plugins, Ctrl+Space prefix, session restore |

Detailed install steps, keymaps, and troubleshooting live in each folder’s guide:

| Component | Guide |
|-----------|--------|
| Zsh + tools | [`zsh/readme.md`](zsh/readme.md) |
| Powerlevel10k | [`p10k/readme.md`](p10k/readme.md) |
| Neovim | [`nvim/readme.md`](nvim/readme.md) |
| Tmux | [`Tmux/readme.md`](Tmux/readme.md) |

---

## Repository layout

```text
My-Workflow/
├── install.sh                # ★ Unified installer (start here)
├── verify.sh / update.sh / uninstall.sh
├── install/
│   ├── catalog.sh            # Master service registry
│   ├── engine.sh             # Menus, presets, execution
│   ├── lib/common.sh
│   ├── dev/                  # Developer workstation modules
│   │   ├── modules/          # system, neovim, zsh-config, …
│   │   └── lib/
│   └── platform/             # DevOps / MLOps / Golden Image
│       ├── packages/         # docker, kubernetes, terraform, …
│       ├── configs/          # git, zsh, tmux, ssh templates
│       ├── verify.sh / update.sh / uninstall.sh
│       └── docs/
├── setup/ → install/dev      # backward-compat symlink
├── golden-image/ → install/platform
├── zsh-dev-full-setup.sh     # legacy → ./install.sh --dev
│
├── zsh/.zshrc
├── p10k/.p10k.zsh
├── nvim/                     # → ~/.config/nvim/
└── Tmux/.tmux.conf
```

On your machine you will also have (not in the repo):

```text
~/.oh-my-zsh/
~/.tmux/plugins/tpm/
~/.local/share/nvim/lazy/
/var/log/golden-image/        # platform install logs
```

---

## Quick start

### Unified installer (recommended)

```bash
git clone https://github.com/Zourvan/My-Workflow.git
cd My-Workflow
./install.sh
```

Interactive menu:

```text
  1) Developer minimal     — shell + dotfiles
  2) Developer full        — shell + editor + CLI tools
  3) Developer IDE         — Neovim + lazygit + superfile
  4) DevOps lab            — Docker, K8s, Terraform, Ansible
  5) MLOps lab             — Python, Docker, AI, cloud
  6) Golden Image (full)   — complete platform stack
  7) Custom selection      — pick any services
  8) List all services
```

### CLI presets

| Command | Installs |
|---------|----------|
| `./install.sh --minimal` | Shell minimal (dev) |
| `./install.sh --dev` | Full developer workstation |
| `./install.sh --ide` | Neovim + tools |
| `./install.sh --devops` | Docker, K8s, Terraform, Ansible, … |
| `./install.sh --mlops` | Python, Docker, AI, cloud |
| `./install.sh --golden` | Full platform (Golden Image) |
| `./install.sh --all` | Everything |
| `./install.sh --only neovim,gi-docker,gi-python` | Cherry-pick |
| `./install.sh --list` | Show all services |

Platform services use `gi-` prefix in catalog (aliases work: `docker` → `gi-docker`).

### Management

```bash
sudo ./verify.sh                    # verify platform installs
sudo ./update.sh                    # upgrade platform packages
sudo ./uninstall.sh gi-docker         # rollback one service
```

### Option A — Golden Image only (VM templates)

```bash
cd My-Workflow
sudo ./install.sh --golden
sudo ./verify.sh
```

Docs: [`install/platform/README.md`](install/platform/README.md) · [`install/platform/docs/INSTALL.md`](install/platform/docs/INSTALL.md)

### Option B — Developer workstation only

```bash
./install.sh --dev
# or interactive: ./install.sh → choose 1, 2, or 3
```

### Option C — Remote bootstrap (legacy)

```bash
curl -fsSL https://raw.githubusercontent.com/Zourvan/My-Workflow/main/zsh-dev-full-setup.sh | bash
```

Runs `./install.sh --dev`.

### Option D — Manual dotfiles only

Replace `/path/to/My Workflow` with your clone path (e.g. `D:\MD\Project\My Workflow` in WSL: `/mnt/d/MD/Project/My Workflow`).

#### 1. Prerequisites

| Requirement | Why |
|-------------|-----|
| **Zsh** | Default shell for this stack |
| **git** | Oh My Zsh plugins, lazy.nvim, TPM |
| **curl** or **wget** | Install scripts |
| **Nerd Font v3** | Icons in p10k, eza, nvim-tree, tmux status |
| **Neovim 0.9+** | Editor |
| **tmux** | Optional but recommended for long sessions |

Install Zsh and set it as login shell (Ubuntu example):

```bash
sudo apt update
sudo apt install -y zsh git curl
chsh -s "$(which zsh)"
```

Log out and back in, then continue in a **Zsh** session.

#### 2. Oh My Zsh + Powerlevel10k + Zsh plugins

Follow [`zsh/readme.md`](zsh/readme.md) sections 2–4 for:

- Oh My Zsh
- Powerlevel10k theme clone
- `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`

#### 3. CLI tools (shell)

From [`zsh/readme.md`](zsh/readme.md) §5 — at minimum for the aliases in `.zshrc`:

```bash
# Debian / Ubuntu example
sudo apt install -y fzf fd-find bat eza ripgrep neovim tmux
# Optional: zoxide, lazygit — see zsh readme for install commands
```

Also install [Superfile](https://superfile.dev/) if you use `sf`, `ff`, `ffz`, or `sfe`.

#### 4. Deploy configs from this repo

Copy or symlink the **entire** `nvim/` folder (not just `init.lua`).

**Copy:**

```bash
REPO="/path/to/My-Workflow"

cp "$REPO/zsh/.zshrc" ~/.zshrc
cp "$REPO/p10k/.p10k.zsh" ~/.p10k.zsh
rm -rf ~/.config/nvim
cp -r "$REPO/nvim" ~/.config/nvim
cp "$REPO/Tmux/.tmux.conf" ~/.tmux.conf
```

**Or symlink** (repo updates apply after reload):

```bash
REPO="/path/to/My-Workflow"

ln -sf "$REPO/zsh/.zshrc" ~/.zshrc
ln -sf "$REPO/p10k/.p10k.zsh" ~/.p10k.zsh
ln -sfn "$REPO/nvim" ~/.config/nvim
ln -sf "$REPO/Tmux/.tmux.conf" ~/.tmux.conf
```

#### 5. Tmux Plugin Manager (one time)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Start tmux, press **Ctrl+Space** then **Shift+I** to install plugins. See [`Tmux/readme.md`](Tmux/readme.md).

#### 6. Neovim plugins (one time)

```bash
nvim
```

Inside Neovim:

```vim
:Lazy sync
```

See [`nvim/readme.md`](nvim/readme.md).

#### 7. Prompt (optional)

If you want to change the prompt interactively instead of using the bundled `.p10k.zsh`:

```bash
p10k configure
```

#### 8. Reload

```bash
exec zsh
```

---

## Recommended install order

```mermaid
flowchart TD
  A[Install Zsh + git] --> B[Oh My Zsh + p10k theme + zsh plugins]
  B --> C[CLI tools: fzf eza bat fd ripgrep neovim tmux]
  C --> D[Copy zsh + p10k + nvim/ + tmux]
  D --> E[Deploy nvim/ → Lazy sync]
  E --> F[Copy Tmux/.tmux.conf + TPM + Prefix+I]
  F --> G[exec zsh — daily use]
```

1. **Shell foundation** — Zsh, Oh My Zsh, plugins, `.zshrc`, `.p10k.zsh`
2. **Editor** — copy `nvim/` → `~/.config/nvim`, `:Lazy sync`, `:TSUpdate` if needed
3. **Tmux** — `.tmux.conf`, TPM, plugin install
4. **Terminal font** — Nerd Font in your terminal emulator settings

Or skip manual steps: `./install.sh --minimal` (shell) or `./install.sh --ide` (editor stack).

Skipping Tmux is fine if you only want shell + Neovim.

---

## How the pieces fit together

```text
┌─────────────────────────────────────────────────────────────┐
│  Terminal (Alacritty, Windows Terminal, iTerm2, …)          │
│  Font: Nerd Font v3                                         │
└───────────────────────────┬─────────────────────────────────┘
                            │
              ┌─────────────▼─────────────┐
              │  tmux (optional)           │
              │  Prefix: Ctrl+Space      │
              │  Catppuccin + TPM plugins  │
              └─────────────┬─────────────┘
                            │
              ┌─────────────▼─────────────┐
              │  zsh + Oh My Zsh          │
              │  p10k prompt, fzf, zoxide │
              │  EDITOR=nvim, v → nvim    │
              └─────────────┬─────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
    neovim            lazygit (lg)      superfile (sf)
    Telescope         git aliases       ffz / sfe → nvim
```

- **Zsh** sets `EDITOR=nvim` and `alias v=nvim`.
- **Neovim** uses **zsh** for `:terminal` / ToggleTerm (`<C-\>`).
- **Tmux** + **vim-tmux-navigator** (plugin) share **Ctrl+h/j/k/l** with Neovim window navigation when the editor plugin is added; Neovim’s built-in maps already use those keys for splits.
- **fzf** (**Ctrl+T**, **Ctrl+R**) and **zoxide** (`z`, `zi`) speed up navigation before you open files in Neovim.

---

## Daily workflow

| Goal | What to run |
|------|-------------|
| New persistent session | `tmux` (detach: **Prefix** `d`) |
| Jump to a project | `z project-name` or `zi` |
| Find a file on disk | **Ctrl+T** (fzf) or `ffz` → Superfile |
| Edit in Neovim | `v .` or `sfe` (pick file in Superfile) |
| Git UI | `lg` (lazygit) |
| Find file inside Neovim | `<Space>ff` (Telescope) |
| Grep in project | `<Space>fg` |
| File tree in Neovim | `<Space>e` |
| Embedded terminal in Neovim | `<C-\>` |
| Docker compose | `dcu` / `dcd` / `dcl` |

After editing dotfiles in this repo:

```bash
source ~/.zshrc          # shell changes
tmux source-file ~/.tmux.conf   # tmux changes
# Neovim: restart or :Lazy sync if plugins changed
```

---

## Keybindings cheat sheet

Leaders and prefixes differ per tool — this table is the **minimum** to remember; full tables are in each sub-guide.

### Zsh / fzf

| Keys | Action |
|------|--------|
| **Ctrl+T** | Fuzzy file → insert path |
| **Ctrl+R** | Fuzzy command history |
| **Alt+C** | Fuzzy directory → `cd` |
| **→** | Accept autosuggestion |

### Neovim (leader = Space)

| Key | Action |
|-----|--------|
| `<leader>e` | File tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help |
| `<C-\>` | Toggle terminal |
| `<C-s>` | Save |
| `<C-h/j/k/l>` | Move between windows |

### Tmux (prefix = Ctrl+Space)

| Keys | Action |
|------|--------|
| **Prefix** `d` | Detach |
| **Prefix** `\|` / `+` | Split horizontal / vertical |
| **Prefix** `I` | Install TPM plugins |
| **Prefix** `[` | Copy mode / scroll |

More: [`Tmux/readme.md`](Tmux/readme.md) · [`nvim/readme.md`](nvim/readme.md) · [`zsh/readme.md`](zsh/readme.md)

---

## Dependency overview

Install details and per-package notes are in [`zsh/readme.md`](zsh/readme.md). Summary:

| Package | Used by |
|---------|---------|
| zsh, Oh My Zsh, Powerlevel10k | Shell + prompt |
| zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions | Shell plugins |
| fzf, fd-find, bat, eza | Shell navigation & listing |
| zoxide | Smart `cd` (`z`, `zi`) |
| lazygit | `lg` |
| superfile | `sf`, `ff`, `ffz`, `sfe` |
| neovim, git, ripgrep | Editor + lazy.nvim + Telescope grep |
| tmux + TPM + plugins | Multiplexer |
| docker / compose | Optional aliases in `.zshrc` |
| build-essential (or equivalent) | Treesitter parser compile |

**Neovim scope:** UI + navigation (lazy.nvim, Treesitter, Telescope, file tree, terminal). No LSP/completion/DAP in the default config — extend `lua/plugins/` when needed. See [`nvim/readme.md`](nvim/readme.md).

---

## Platform notes

### Linux / macOS

Use the paths above (`~/.zshrc`, `~/.config/nvim/`, etc.). macOS: prefer `brew install` for tools — see [`zsh/readme.md`](zsh/readme.md).

### Windows

| Approach | Shell / Tmux | Neovim |
|----------|----------------|--------|
| **WSL2** (recommended) | Full stack as on Linux | `~/.config/nvim/` inside WSL (whole `nvim/` tree) |
| **Native Windows** | Limited; use WSL for Zsh/Tmux | `%LOCALAPPDATA%\nvim\init.lua` — see [`nvim/readme.md`](nvim/readme.md) |

`init.lua` sets `shell = "zsh"`. On native Windows without WSL, change shell in `init.lua` or run Neovim from WSL only.

### Terminal font

Install a **Nerd Font v3** (e.g. MesloLGS NF, JetBrainsMono Nerd Font) and select it in your terminal settings. Without it, prompt and UI icons may show as boxes.

---

## Customization

| Change | Edit | Reload |
|--------|------|--------|
| Aliases, fzf, zoxide | `zsh/.zshrc` | `source ~/.zshrc` |
| Prompt segments | `p10k/.p10k.zsh` or `p10k configure` | `source ~/.p10k.zsh` |
| Editor plugins / keys | `nvim/` (`lua/plugins/`, `lua/config/`) | Restart nvim / `:Lazy sync` |
| Tmux theme / plugins | `Tmux/.tmux.conf` | `tmux source-file ~/.tmux.conf` |

Keep Powerlevel10k **instant prompt** at the top of `.zshrc` (already in the repo file). Avoid slow commands above that block.

---

## Troubleshooting (index)

| Symptom | See |
|---------|-----|
| Installer / golden image issues | [`install/platform/docs/INSTALL.md`](install/platform/docs/INSTALL.md), `/var/log/golden-image/` |
| Service install failed | Re-run `./install.sh --only <service-id>` |
| Oh My Zsh / prompt broken | [`zsh/readme.md`](zsh/readme.md), [`p10k/readme.md`](p10k/readme.md) |
| `command not found: eza`, `bat`, `fdfind` | [`zsh/readme.md`](zsh/readme.md) §5, Ubuntu aliases in `.zshrc` |
| fzf keys not working | Install `fzf` package + key-bindings path |
| Neovim plugins missing | `:Lazy sync`, git on PATH |
| Telescope grep empty | Install `ripgrep` |
| Tmux plugins not loading | TPM clone, **Prefix+I**, `run` line last in `.tmux.conf` |
| Tmux + Neovim pane navigation | [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) (not in `init.lua` yet) |

---

## Maintenance

**Update configs from git:**

```bash
cd "/path/to/My Workflow"
git pull
# If using symlinks, reload shell/tmux/nvim as needed
```

**Update plugins:**

| Tool | Command / keys |
|------|----------------|
| Neovim | `:Lazy sync` |
| Tmux | **Prefix** `u` (TPM update) |
| Oh My Zsh | `omz update` |
| p10k | Re-run `p10k configure` or edit `~/.p10k.zsh` |

---

## Links

- **Installer:** [`install.sh`](install.sh) · [`install/catalog.sh`](install/catalog.sh) · [`install/platform/README.md`](install/platform/README.md)
- [Oh My Zsh](https://ohmyzsh.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Tmux TPM](https://github.com/tmux-plugins/tpm)
- [fzf](https://github.com/junegunn/fzf) · [zoxide](https://github.com/ajeetdsouza/zoxide) · [eza](https://github.com/eza-community/eza)
- [lazygit](https://github.com/jesseduffield/lazygit) · [Superfile](https://superfile.dev/)

---

## License

Personal dotfiles and automation — use and adapt as you like. Platform framework: MIT ([`install/platform/LICENSE`](install/platform/LICENSE)). No warranty; test on a non-production machine first.

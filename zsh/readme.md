# Zsh setup guide

This folder contains [`.zshrc`](./.zshrc): an **Oh My Zsh**–based shell config with **Powerlevel10k**, productivity plugins, **fzf**, **zoxide**, modern CLI tools, and aliases for Git, Docker, and daily dev work.

---

## Quick start

| Step | What to do |
|------|------------|
| 1 | Install Zsh and dependencies (see below) |
| 2 | Install Oh My Zsh, theme, and custom plugins |
| 3 | Copy or symlink `.zshrc` to `~/.zshrc` |
| 4 | Run `p10k configure` once (optional but recommended) |
| 5 | Restart the shell: `exec zsh` |

---

## Install this config

Copy or link the file into your home directory:

```bash
# From this repo (adjust the path if yours differs)
cp "/path/to/My Workflow/zsh/.zshrc" ~/.zshrc
```

Or symlink so updates in the repo apply automatically:

```bash
ln -sf "/path/to/My Workflow/zsh/.zshrc" ~/.zshrc
```

Reload after changes:

```bash
source ~/.zshrc
# or
exec zsh
```

---

## Complete dependency checklist (from `.zshrc`)

Everything this config touches, and how to install it.

| Dependency | Used for | Install method |
|------------|----------|----------------|
| **zsh** | Shell | §1 — `apt` / `dnf` / `brew` |
| **Oh My Zsh** | Framework (`$ZSH`) | §2 — install script |
| **Powerlevel10k** | `ZSH_THEME`, instant prompt, `p10k` | §3 — `git clone` into `custom/themes/` |
| **zsh-autosuggestions** | Plugin | §4 — `git clone` |
| **zsh-syntax-highlighting** | Plugin | §4 — `git clone` |
| **zsh-completions** | Plugin | §4 — `git clone` |
| **fzf** | Fuzzy find, `ffz`, key bindings | §5 — `apt` / `dnf` / `brew` |
| **fd-find** (`fdfind`) | `FZF_DEFAULT_COMMAND`, `fd` alias | §5 — package `fd-find` (Ubuntu) |
| **find** | fzf fallback if no `fdfind` | Usually preinstalled (`findutils`) |
| **eza** | `ll`, `tree`, `chpwd` listing | §5 |
| **bat** (`batcat` on Ubuntu) | `ffz` preview | §5 — package `bat` |
| **zoxide** | `z`, `zi`, `cd` alias | §5 |
| **lazygit** | `lg` alias | §5 |
| **neovim** | `EDITOR`, `v`, `spfedit` | §5 |
| **superfile** (`spf`) | `sf`, `ff`, `ffz`, `sfe` | §6 — install script |
| **git** | Git aliases, OMZ `git` plugin | §5 |
| **docker** + **compose** | Docker aliases, OMZ plugins | §5 — optional if you do not use Docker |
| **curl** | `myip` alias | §5 |
| **lsof** | `listen` alias | §5 — package `lsof` |
| **iproute2** | `ports` alias (`ss`) | §5 — package `iproute2` |
| **command-not-found** | OMZ plugin (Ubuntu) | §5 — package `command-not-found` |
| **ls**, **clear** | `la`, `l`, `cls` | Usually preinstalled (`coreutils`) |
| **wget** | Alternative Oh My Zsh installer | Optional — `apt install wget` |
| **Archive tools** | OMZ `extract` plugin | Optional — see §5 note below |

Built-in Oh My Zsh plugins (no extra install): `git`, `docker`, `docker-compose`, `sudo`, `extract`, `colored-man-pages`, `command-not-found`.

---

## Install dependencies

### 1. Zsh (required)

**Debian / Ubuntu**

```bash
sudo apt update
sudo apt install -y zsh
chsh -s "$(which zsh)"
```

**Fedora / RHEL**

```bash
sudo dnf install -y zsh
chsh -s "$(which zsh)"
```

**macOS**

```bash
brew install zsh
chsh -s "$(brew --prefix)/bin/zsh"
```

Log out and back in (or open a new terminal) after `chsh`.

---

### 2. Oh My Zsh (required)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Or with wget:

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

The config expects `ZSH` at `~/.oh-my-zsh` (Oh My Zsh default).

---

### 3. Powerlevel10k theme (required for `ZSH_THEME`)

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

After first login with this `.zshrc`, run the wizard:

```bash
p10k configure
```

That writes `~/.p10k.zsh`, which this config sources automatically.

---

### 4. Oh My Zsh custom plugins (required)

Install into `~/.oh-my-zsh/custom/plugins/`:

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

git clone https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

git clone https://github.com/zsh-users/zsh-completions \
  "$ZSH_CUSTOM/plugins/zsh-completions"
```

**Plugin order:** Upstream recommends loading **zsh-syntax-highlighting last** among custom plugins. This `.zshrc` lists `zsh-completions` after it; if highlighting looks wrong, move `zsh-syntax-highlighting` to the end of the `plugins=(...)` array.

---

### 5. CLI tools used by aliases and functions

**Debian / Ubuntu**

```bash
sudo apt update
sudo apt install -y \
  zsh \
  fzf \
  fd-find \
  bat \
  eza \
  zoxide \
  lazygit \
  neovim \
  curl \
  git \
  lsof \
  iproute2 \
  command-not-found \
  docker.io \
  docker-compose-plugin
```

**One-liner (copy-paste, Ubuntu/Debian):**

```bash
sudo apt update && sudo apt install -y zsh fzf fd-find bat eza zoxide lazygit neovim curl git lsof iproute2 command-not-found docker.io docker-compose-plugin
```

On Ubuntu, `fd` is installed as **`fdfind`** and `bat` as **`batcat`**. This config aliases them to `fd` and `bat` when those binaries exist.

**Optional — `extract` plugin (archives):** install tools as you need them:

```bash
sudo apt install -y unzip p7zip-full xz-utils bzip2
# unrar is in multiverse on some Ubuntu releases:
# sudo apt install -y unrar
```

**Fedora / RHEL (names may differ)**

```bash
sudo dnf install -y zsh fzf fd-find bat eza zoxide lazygit neovim curl git lsof iproute procps-ng command-not-found docker docker-compose
```

**macOS (Homebrew)**

```bash
brew install zsh fzf fd bat eza zoxide lazygit neovim git lsof curl docker docker-compose
```

On macOS, `ss` (used by `ports`) is not the same as Linux; the `ports` alias is aimed at Linux. Use `lsof -i -P -n` or `netstat` on macOS if needed.

After installing **fzf** on Linux, key bindings and completion often live under:

```text
/usr/share/doc/fzf/examples/key-bindings.zsh
/usr/share/doc/fzf/examples/completion.zsh
```

This `.zshrc` sources those paths when present.

---

### 6. Superfile (`spf`) — optional but used by aliases

```bash
bash -c "$(curl -sLo- https://superfile.dev/install.sh)"
```

Aliases: `sf`, `ff`, custom functions `ffz` and `spfedit` (`sfe`).

---

## What this `.zshrc` does

### Powerlevel10k instant prompt

Lines at the top load the instant prompt cache from `~/.cache` when available so the prompt appears faster. Keep password prompts and interactive setup **above** that block if you add more init code.

### Oh My Zsh core

| Setting | Purpose |
|---------|---------|
| `ZSH_THEME="powerlevel10k/powerlevel10k"` | Prompt theme |
| Built-in plugins | `git`, `docker`, `docker-compose`, `sudo`, `extract`, `colored-man-pages`, `command-not-found` |
| Custom plugins | Autosuggestions, syntax highlighting, extra completions |

### History

| Option | Effect |
|--------|--------|
| `HISTSIZE` / `SAVEHIST` `10000` | Keep up to 10k lines |
| `APPEND_HISTORY` | Append instead of overwrite |
| `SHARE_HISTORY` | Share history across sessions |
| `HIST_IGNORE_DUPS` | Skip duplicate lines |
| `HIST_IGNORE_SPACE` | Lines starting with space are not saved |

### Shell behavior

| Option | Effect |
|--------|--------|
| `AUTO_CD` | Type a directory name to `cd` into it |
| `INTERACTIVE_COMMENTS` | Allow `#` comments in interactive shell |
| `NO_BEEP` | Disable terminal bell |
| `compinit` | Enable completion system |

### fzf integration

- Default file search uses **`fdfind`** when available (respects hidden files, excludes `.git`); otherwise falls back to `find`.
- `FZF_CTRL_T_COMMAND` matches the default file command.
- Loads official fzf **key bindings** and **completion** scripts when installed via the distro package.

### zoxide (smart directory jump)

- `eval "$(zoxide init zsh)"` — tracks directories you visit.
- `alias cd="z"` — normal `cd` goes through zoxide.
- `alias cdi="zi"` — interactive pick.

Examples:

```bash
z myproject          # jump to a dir you've used before
zi                   # fuzzy pick from history
```

### Directory listing on `cd`

The `chpwd` hook runs **`eza`** after every directory change (icons, groups dirs first).

### Editor

`EDITOR` and `nvim` alias `v` are set to **Neovim**.

### PATH

`$HOME/.local/bin` is prepended to `PATH` (user-local binaries).

### Custom functions

| Function / alias | What it does |
|------------------|--------------|
| `ffz` | fzf file picker with `bat` preview → opens parent dir in Superfile |
| `spfedit` / `sfe` | Pick a file in Superfile → open in Neovim |

---

## Aliases reference

### General & listing

| Alias | Command |
|-------|---------|
| `ll` | `eza -lah` with icons, sizes, octal perms, dirs first |
| `la` | `ls -A` |
| `l` | `ls -CF` |
| `cls` | `clear` |
| `tree` | `eza -T` with icons |
| `v` | `nvim` |

### Git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `lg` | `lazygit` |

Oh My Zsh **git** plugin also adds many `g*` shortcuts; your explicit aliases above take precedence where names overlap.

### Docker

| Alias | Command |
|-------|---------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dps` | `docker ps` |
| `dimg` | `docker images` |
| `dlog` | `docker logs -f` |
| `dexec` | `docker exec -it` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |
| `dcl` | `docker compose logs -f` |

### Network

| Alias | Command |
|-------|---------|
| `ports` | `ss -tulpen` |
| `myip` | `curl -s ifconfig.me` |
| `listen` | `lsof -i -P -n` |

### Tools

| Alias | Command |
|-------|---------|
| `sf` | `spf` (Superfile) |
| `ff` | `spf .` (Superfile in current dir) |
| `fd` | `fdfind` (Ubuntu only, if `fdfind` exists) |
| `bat` | `batcat` (Ubuntu only, if `batcat` exists) |

---

## Keyboard reference

### fzf (when key-bindings.zsh is loaded)

| Keys | Action |
|------|--------|
| **Ctrl + T** | Fuzzy-find files/dirs and insert on the command line |
| **Ctrl + R** | Fuzzy-search command history |
| **Alt + C** | Fuzzy-find a directory and `cd` into it |
| **Tab** (after partial path) | fzf completion (when completion.zsh is loaded) |

Within the fzf UI (typical defaults):

| Keys | Action |
|------|--------|
| **↑ / ↓** or **Ctrl + N / P** | Move selection |
| **Enter** | Confirm |
| **Esc** | Cancel |
| **Ctrl + /** | Toggle preview (if enabled) |

### zsh-autosuggestions

| Keys | Action |
|------|--------|
| **→** (End) | Accept full suggestion |
| **Alt + →** | Accept one word |
| **Ctrl + →** | Accept one word (if configured) |
| Keep typing | Ignore suggestion |

Suggestion text is usually gray; it comes from history.

### Oh My Zsh `sudo` plugin

| Keys | Action |
|------|--------|
| **Esc** **Esc** | Prefix current (or previous) command line with `sudo` |

### `extract` plugin

| Command | Action |
|---------|--------|
| `extract <archive>` | Decompress many formats (tar, zip, gz, etc.) |

### Completion

| Keys | Action |
|------|--------|
| **Tab** | Complete command / path |
| **Tab Tab** | Show completion menu |

### Line editing (default Zsh emacs mode)

| Keys | Action |
|------|--------|
| **Ctrl + A** | Beginning of line |
| **Ctrl + E** | End of line |
| **Ctrl + U** | Kill to beginning of line |
| **Ctrl + K** | Kill to end of line |
| **Ctrl + W** | Kill previous word |
| **Alt + B / F** | Word backward / forward |
| **Ctrl + L** | Clear screen (`cls` alias also works) |

### Powerlevel10k

Run **`p10k configure`** to change prompt segments, icons, and style interactively. Config is stored in `~/.p10k.zsh`.

---

## Oh My Zsh plugin behavior (built-in)

| Plugin | What you get |
|--------|----------------|
| **git** | Extra Git aliases and tab completion |
| **docker** | Docker command completion |
| **docker-compose** | Compose completion |
| **sudo** | Double-Esc `sudo` (see keyboard table) |
| **extract** | `extract` command for archives |
| **colored-man-pages** | Syntax-colored `man` pages |
| **command-not-found** | Suggests packages when a command is missing (Ubuntu) |

---

## Useful daily workflow

1. **First-time prompt** — Run `p10k configure` after installing Powerlevel10k.
2. **Jump to a project** — `z repo-name` or `zi` for interactive list.
3. **Find a file** — **Ctrl + T** (fzf) or run `ffz` to open Superfile on the file’s directory.
4. **Edit via Superfile** — `sfe` to pick a file and open in Neovim.
5. **Git TUI** — `lg` or `lazygit`.
6. **Containers** — `dcu` / `dcd` / `dcl` for compose workflows.
7. **After editing `.zshrc`** — `source ~/.zshrc` or `exec zsh`.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ZSH not found` / Oh My Zsh errors | Install Oh My Zsh; ensure `~/.oh-my-zsh` exists |
| Prompt looks broken | Install Powerlevel10k theme; run `p10k configure` |
| `command not found: eza` / `bat` / `fdfind` | Install packages (see §5); on Ubuntu use `batcat` / `fdfind` or the aliases in this config |
| fzf keys do nothing | Install `fzf` package; check files under `/usr/share/doc/fzf/examples/` |
| No autosuggestions / wrong highlight colors | Clone custom plugins; put **zsh-syntax-highlighting** last in `plugins=(...)` |
| `spf` / `ffz` / `sfe` fail | Install [Superfile](https://superfile.dev/); install `bat` for `ffz` preview |
| `listen: command not found` | `sudo apt install -y lsof` |
| `ss: command not found` | `sudo apt install -y iproute2` |
| `command-not-found` plugin silent | `sudo apt install -y command-not-found` (Ubuntu) |
| `extract` fails on some archives | Install `unzip`, `p7zip-full`, etc. (see §5 optional) |
| `z` does not learn paths | Ensure `zoxide` is installed and `eval "$(zoxide init zsh)"` runs (already in `.zshrc`) |
| Custom `PROMPT` ignored | Powerlevel10k from `~/.p10k.zsh` overrides the fallback `PROMPT` line when present |
| Docker aliases fail | Install Docker and ensure your user can run `docker` (group membership / rootless setup) |

---

## File layout

```text
zsh/
├── .zshrc      # Main config (copy to ~/.zshrc)
└── readme.md   # This guide
```

Related files outside this folder (created on your machine, not in the repo):

```text
~/.oh-my-zsh/           # Oh My Zsh install
~/.p10k.zsh             # Powerlevel10k config (after p10k configure)
~/.zsh_history          # Command history
~/.cache/p10k-*         # Instant prompt cache
```

---

## Links

- [Oh My Zsh](https://ohmyzsh.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [eza](https://github.com/eza-community/eza)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [Superfile](https://superfile.dev/)

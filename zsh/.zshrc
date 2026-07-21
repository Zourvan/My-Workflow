# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# =========================================
# ZSH CORE
# =========================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  docker
  docker-compose
  sudo
  extract
  colored-man-pages
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh

# =========================================
# HISTORY
# =========================================

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# =========================================
# ZSH BEHAVIOR
# =========================================

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# =========================================
# FZF (Ubuntu-safe)
# =========================================

if command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
else
  export FZF_DEFAULT_COMMAND='find . -type f'
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# =========================================
# ALIASES - GENERAL
# =========================================

alias ll='eza -lah --icons --sort=name --group-directories-first --total-size --octal-permissions'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias tree='eza -T --icons'
# =========================================
# GIT
# =========================================

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# =========================================
# DOCKER
# =========================================

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dimg='docker images'
alias dlog='docker logs -f'
alias dexec='docker exec -it'

alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# =========================================
# NETWORK
# =========================================

alias ports='ss -tulpen'
alias myip='curl -s ifconfig.me'
alias listen='lsof -i -P -n'

# =========================================
# UBUNTU COMPATIBILITY
# =========================================

if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi

# =========================================
# PROMPT
# =========================================

export PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '

# =========================================
# PATH
# =========================================

export PATH="$HOME/.local/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(zoxide init --cmd cd zsh)"

eval "$(zoxide init zsh)"
alias cd="z"
alias cdi="zi"


alias lg="lazygit"
alias sf="spf"
alias ff="spf ."
export EDITOR="nvim"
alias v="nvim"


ffz() {
  local file
  file=$(fzf --preview="bat {}") || return
  [ -n "$file" ] && spf "$(dirname "$file")"
}


spfedit() {
  local file
  file=$(spf --pick 2>/dev/null || true)
  [ -n "$file" ] && nvim "$file"
}
alias sfe="spfedit"


chpwd() {
   eza -a --icons --group-directories-first
}

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
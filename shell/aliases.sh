# Sourced from ~/.bashrc by install.sh
alias k='kubectl'
alias kgp='kubectl get pods'
alias kga='kubectl get all'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'
alias v='nvim'
alias vim='nvim'

export EDITOR=nvim
export VISUAL=nvim

# eza/bat replacements — only when the tool actually installed
if command -v eza >/dev/null 2>&1; then
	alias ls='eza --icons'
	alias ll='eza -l --icons --git'
	alias la='eza -la --icons --git'
	alias tree='eza --tree --icons'
fi

# debian/ubuntu apt packages bat as "batcat"
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
	alias cat='bat --paging=never'
fi

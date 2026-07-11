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

# eza/bat replacements — only when the tool actually installed.
# --icons must use = form: bare "--icons" makes newer eza eat the next
# argument as its WHEN value ("ls somedir" then errors out).
if command -v eza >/dev/null 2>&1; then
	alias ls='eza --icons=auto'
	alias ll='eza -l --icons=auto --git'
	alias la='eza -la --icons=auto --git'
	alias tree='eza --tree --icons=auto'
fi

# debian/ubuntu apt packages bat as "batcat"
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
	alias cat='bat --paging=never'
fi

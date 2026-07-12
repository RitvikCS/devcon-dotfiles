# Sourced from ~/.bashrc by install.sh
# Each init is guarded so a machine where a tool didn't install still works.

# Export SHELL for child processes. When the environment lacks SHELL (e.g.
# `devcontainer exec bash`), bash sets the variable from /etc/passwd but does
# NOT export it — so nvim's :terminal falls back to plain sh (no bashrc, no
# starship, no aliases).
export SHELL="${SHELL:-/bin/bash}"

# fzf: Ctrl+R history, Ctrl+T files, Alt+C cd
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"

# zoxide: z <dir> jumps, zi picks interactively
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# fnm: only present where install.sh found no node (bare work VMs);
# containers get node from the devcontainer feature instead.
if [ -d "$HOME/.local/share/fnm" ] && ! command -v fnm >/dev/null 2>&1; then
	export PATH="$HOME/.local/share/fnm:$PATH"
fi
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell bash)"

# starship last so nothing below clobbers the prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

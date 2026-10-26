# Sourced from ~/.bashrc by install.sh
# Each init is guarded so a machine where a tool didn't install still works.

# Export SHELL for child processes. When the environment lacks SHELL (e.g.
# `devcontainer exec bash`), bash sets the variable from /etc/passwd but does
# NOT export it — so nvim's :terminal falls back to plain sh (no bashrc, no
# starship, no aliases).
export SHELL="${SHELL:-/bin/bash}"

# fzf: Ctrl+R history, Ctrl+T files, Alt+C cd
# `fzf --bash` needs fzf >= 0.48; Ubuntu 24.04's apt has 0.44, which ships
# the bindings as a file instead.
if command -v fzf >/dev/null 2>&1; then
	if fzf --bash >/dev/null 2>&1; then
		eval "$(fzf --bash)"
	elif [ -r /usr/share/doc/fzf/examples/key-bindings.bash ]; then
		. /usr/share/doc/fzf/examples/key-bindings.bash
	fi
fi

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

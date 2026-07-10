#!/usr/bin/env bash
# Dotfiles bootstrap. The devcontainer CLI clones this repo into the
# container and runs this script when `devcontainer up` is given
# --dotfiles-repository (install.sh is picked up by name automatically).
# Idempotent: safe to run more than once.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Link every directory under config/ into ~/.config (nvim/, etc.).
# Symlinks (not copies) so a `git pull` in the dotfiles clone updates live.
if [ -d "$DOTFILES_DIR/config" ]; then
	mkdir -p "$HOME/.config"
	for dir in "$DOTFILES_DIR"/config/*/; do
		[ -d "$dir" ] || continue
		name="$(basename "$dir")"
		rm -rf "$HOME/.config/$name"
		ln -sfn "${dir%/}" "$HOME/.config/$name"
		echo "linked ~/.config/$name"
	done
fi

# Source every shell/*.sh from .bashrc (aliases, prompt, env).
MARKER="# >>> devcon-dotfiles >>>"
if [ -d "$DOTFILES_DIR/shell" ] && ! grep -qF "$MARKER" "$HOME/.bashrc" 2>/dev/null; then
	cat >>"$HOME/.bashrc" <<EOF

$MARKER
for f in "$DOTFILES_DIR"/shell/*.sh; do [ -r "\$f" ] && . "\$f"; done
# <<< devcon-dotfiles <<<
EOF
	echo "hooked shell/ into ~/.bashrc"
fi

echo "devcon-dotfiles: done."

#!/usr/bin/env bash
# Dotfiles bootstrap. The devcontainer CLI clones this repo into the
# container and runs this script when `devcontainer up` is given
# --dotfiles-repository (install.sh is picked up by name automatically).
# Also usable standalone on a bare VM: git clone + ./install.sh.
# Idempotent: safe to run more than once.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- CLI tools (eza, bat, fzf, zoxide, starship) -----------------------------
# brew when available (containers have it via the neovim-homebrew feature),
# apt fallback for bare VMs, curl installer for what apt doesn't carry.

have() { command -v "$1" >/dev/null 2>&1; }

missing=()
have eza || missing+=(eza)
have bat || have batcat || missing+=(bat)
have fzf || missing+=(fzf)
have zoxide || missing+=(zoxide)
have starship || missing+=(starship)

if [ ${#missing[@]} -gt 0 ]; then
	echo "installing: ${missing[*]}"
	if have brew; then
		brew install "${missing[@]}" || echo "warn: brew install had failures, continuing"
	elif have apt-get; then
		SUDO=""
		[ "$(id -u)" -ne 0 ] && SUDO="sudo"
		$SUDO apt-get update -qq || true
		for pkg in "${missing[@]}"; do
			if [ "$pkg" = starship ]; then
				# not in debian/ubuntu repos — official installer
				curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null
			else
				$SUDO apt-get install -y -qq "$pkg" || echo "warn: apt has no $pkg, skipping"
			fi
		done
	else
		echo "warn: no brew or apt-get, skipped: ${missing[*]}"
	fi
fi

# fnm unless node already comes from somewhere managed: containers get node
# from the devcontainer feature (under /usr/local/share/nvm). A node in
# /usr/bin is the distro package, often pulled in by apt as a recommended
# dependency (e.g. of tree-sitter-cli), so it doesn't count.
if ! have fnm; then
	node_path="$(command -v node 2>/dev/null || true)"
	case "$node_path" in
	"" | /usr/bin/node)
		echo "no managed node found — installing fnm"
		curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
		;;
	esac
fi

# --- Config links -------------------------------------------------------------
# Symlinks (not copies) so a `git pull` in the dotfiles clone updates live.
# Anything already there that isn't a symlink is moved aside to *.bak.

link() {
	local src="$1" dst="$2"
	if [ -e "$dst" ] && [ ! -L "$dst" ]; then
		mv "$dst" "$dst.bak"
		echo "backed up $dst -> $dst.bak"
	fi
	ln -sfn "$src" "$dst"
	echo "linked $dst"
}

mkdir -p "$HOME/.config"
for entry in "$DOTFILES_DIR"/config/*; do
	[ -e "$entry" ] || continue
	link "$entry" "$HOME/.config/$(basename "$entry")"
done

# --- Shell hook ---------------------------------------------------------------
# Source every shell/*.sh from .bashrc (aliases, tool inits, env).
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

# Sourced from ~/.bashrc by install.sh. WSL only: send links and files that
# Linux tools open (gh, claude, python's webbrowser, xdg-open) to Windows.
# Ubuntu 26.04 dropped wslu (wslview), which used to do this.
if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
	_dotfiles_bin="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)"
	case ":$PATH:" in *":$_dotfiles_bin:"*) ;; *) export PATH="$_dotfiles_bin:$PATH" ;; esac
	export BROWSER="$_dotfiles_bin/wsl-open"
	alias open='wsl-open'
	unset _dotfiles_bin
fi

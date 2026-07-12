# devcon-dotfiles

Devcontainer templates + dotfiles, driven by the [devcontainer CLI](https://github.com/devcontainers/cli).
One repo, two jobs:

1. **`devcontainer-templates/`** — ready-made `devcontainer.json` configs you copy
   into projects. There is no inheritance in devcontainer.json, so each variant
   repeats the base features and adds its own on top.
2. **Dotfiles** (`install.sh`, `config/`, `shell/`) — the CLI clones this repo into
   every container (when told to, see below) and runs `install.sh`, which installs
   CLI tools (eza, bat, fzf, zoxide, starship), links `config/*` into `~/.config`
   (LazyVim starter + starship.toml), and hooks `shell/*.sh` into `.bashrc`.
   Also works standalone on a bare VM: `git clone` + `./install.sh` — anything
   already in place is backed up to `*.bak`, never deleted, and fnm+node are
   installed only when the machine has no node at all.

## Templates

| Template | Adds on top of base |
|---|---|
| `base/` | — (ubuntu 26.04, python 3.12, node LTS, kubectl, helm, neovim from apt) |
| `aws/` | aws-cli, terraform, `~/.aws` bind mount |
| `azure/` | azure-cli, `~/.azure` bind mount |
| `gcp/` | gcloud, `~/.config/gcloud` bind mount |
| `k8s-lab/` | docker-in-docker, kind — throwaway clusters for CKA practice |

## Using a template in a project

Copy the variant you want into the project as `.devcontainer/devcontainer.json`:

```sh
mkdir -p myproject/.devcontainer
cp devcontainer-templates/aws/devcontainer.json myproject/.devcontainer/
```

## Starting a container with these dotfiles

From the project folder, bring the container up with the dotfiles flags, then
exec into it:

```sh
devcontainer up --workspace-folder . \
  --dotfiles-repository https://github.com/RitvikCS/devcon-dotfiles

devcontainer exec --workspace-folder . bash
```

The dotfiles flags on `devcontainer up`:

| Flag | What it does | Default |
|---|---|---|
| `--dotfiles-repository` | Git URL to clone into the container after creation | — (off) |
| `--dotfiles-target-path` | Where the repo is cloned inside the container | `~/dotfiles` |
| `--dotfiles-install-command` | Script to run after cloning | first of `install.sh`, `install`, `bootstrap.sh`, `bootstrap`, `setup.sh`, `setup` found in the repo root |

Only `--dotfiles-repository` is needed here — this repo's `install.sh` is
picked up by the default. Dotfiles are applied once at container creation; to
re-apply after changing them, rebuild with:

```sh
devcontainer up --workspace-folder . --remove-existing-container \
  --dotfiles-repository https://github.com/RitvikCS/devcon-dotfiles
```

To avoid retyping the flag, alias it on the host:

```sh
alias dcup='devcontainer up --workspace-folder . --dotfiles-repository https://github.com/RitvikCS/devcon-dotfiles'
alias dcsh='devcontainer exec --workspace-folder . bash'
```

A repo can also carry several configs side by side as
`.devcontainer/<name>/devcontainer.json`; pick one with
`devcontainer up --workspace-folder . --config .devcontainer/<name>/devcontainer.json`.
(VS Code and Codespaces also read these; there you set the dotfiles repo in
user settings — `dotfiles.repository` — instead of a flag.)

## Inside the container

- **apt**: run `sudo apt-get update` once before installing anything — the
  image ships with empty apt package lists (keeps layers small), so a bare
  `apt install foo` fails with "Unable to locate package". The `vscode` user
  has passwordless sudo; `sudo -i` gives a root shell.
- **Where am I**: the project is bind-mounted at `/workspaces/<project-name>`
  and shells start there. If you wander off to `~`, `cd -` goes back, and
  zoxide remembers any directory you've visited (`z <name>`).
- **Why `.bashrc` looks crowded**: that's the image's stock bashrc (Ubuntu
  skel + devcontainer additions). The dotfiles only append the 4-line
  `# >>> devcon-dotfiles >>>` block at the bottom — aliases, starship init,
  and tool hooks all live in `~/dotfiles/shell/*.sh`, which that block sources.
- **Disk housekeeping**: rebuilds leave dangling images behind — check with
  `docker system df`, reclaim with `docker image prune`. Projects sharing the
  same base image + feature stack share layers, so N containers cost far less
  than N × image size.

## Stopping and cleaning up

The devcontainer CLI has no `stop`/`down` — lifecycle is plain docker. Find a
project's container with the label the CLI stamps on it:

```sh
docker ps -aq --filter label=devcontainer.local_folder=$(pwd)
```

- **Done for the day**: `docker stop <id>` is all you need. Do NOT `docker rm`
  — the next `devcontainer up` restarts the stopped container in seconds
  instead of rebuilding, and nvim plugins / installed packages survive.
- **Fresh start** (changed devcontainer.json or dotfiles):
  `devcontainer up --workspace-folder . --remove-existing-container ...`
  (or `docker rm -f <id>` first).
- **Leave the `vsc-<project>-...` images alone** between sessions: the two
  entries (`-features` and `-features-uid`) share almost all layers — not
  double the size — and deleting them forces a full feature rebuild next `up`.
- **Avoid routine `docker system prune -a`**: it deletes every image not used
  by a *running* container — including base and vsc images while yours is
  stopped — meaning a full re-download next time. Routine cleanup is
  `docker image prune` (dangling only) and occasionally `docker builder prune`;
  save `prune -a` for when you deliberately want the disk back.

## Notes

- Neovim comes from the plain ubuntu archive (0.11.6 on 26.04, above LazyVim's
  0.11.2 minimum) via the generic `rocker-org/.../apt-packages` feature.
  History of the alternatives: the `neovim-homebrew` feature dragged in the
  whole Homebrew toolchain (~2.5 GB per image); the `stu-bell` AppImage feature
  bakes `XDG_CONFIG_HOME=/config` into the image, which silently redirects
  nvim's config lookup away from `~/.config` (LazyVim never loads); the
  `neovim-apt-get` feature uses the abandoned neovim PPA (v0.7.2, no 26.04
  builds). Distro apt is the boring option that just works.
- The nvim config is the stock [LazyVim starter](https://github.com/LazyVim/starter)
  plus one tweak (`lua/plugins/explorer.lua`: snacks explorer opens focused on
  the file list; Alt+w cycles list <-> filter input). First `nvim` launch in a
  new container downloads plugins — give it a minute.
- No fonts are installed in containers: glyphs (starship symbols, eza icons)
  are rendered by the host terminal's Nerd Font, which travels with you, not
  with the container.
- The cloud variants bind-mount host credential dirs — `mkdir -p` them on the
  host first or docker creates them root-owned.
- Node is installed via the official feature (nvm-based, version pinned in the
  json). fnm is deliberately not used: version switching per project is what
  containers already do.

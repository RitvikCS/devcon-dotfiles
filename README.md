# devcon-dotfiles

Devcontainer templates + dotfiles, driven by the [devcontainer CLI](https://github.com/devcontainers/cli).
One repo, two jobs:

1. **`devcontainer-templates/`** — ready-made `devcontainer.json` configs you copy
   into projects. There is no inheritance in devcontainer.json, so each variant
   repeats the base features and adds its own on top.
2. **Dotfiles** (`install.sh`, `config/`, `shell/`) — the CLI clones this repo into
   every container (when told to, see below) and runs `install.sh`, which links
   `config/*` into `~/.config` and hooks `shell/*.sh` into `.bashrc`.

## Templates

| Template | Adds on top of base |
|---|---|
| `base/` | — (debian bookworm, python 3.12, node LTS, kubectl, helm, neovim) |
| `aws/` | aws-cli, terraform, `~/.aws` bind mount |
| `azure/` | azure-cli, `~/.azure` bind mount |
| `gcp/` | gcloud, `~/.config/gcloud` bind mount |
| `k8s-lab/` | docker-in-docker, kind — throwaway clusters for CKA practice |

## Using a template in a project

Copy the variant you want into the project, bring the container up with the
dotfiles flag, and exec into it:

```sh
mkdir -p myproject/.devcontainer
cp devcontainer-templates/aws/devcontainer.json myproject/.devcontainer/

cd myproject
devcontainer up --workspace-folder . \
  --dotfiles-repository https://github.com/RitvikCS/devcon-dotfiles
devcontainer exec --workspace-folder . bash
```

`install.sh` is run automatically after cloning (the CLI looks for it by name;
default clone path is `~/dotfiles` inside the container).

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

## Notes

- First build of any template takes a few minutes (neovim compiles from
  source); rebuilds are cached.
- The cloud variants bind-mount host credential dirs — `mkdir -p` them on the
  host first or docker creates them root-owned.
- Node is installed via the official feature (nvm-based, version pinned in the
  json). fnm is deliberately not used: version switching per project is what
  containers already do.

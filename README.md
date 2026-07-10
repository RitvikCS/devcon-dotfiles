# devcon-dotfiles

Devcontainer templates + dotfiles for DevPod workspaces. One repo, two jobs:

1. **`devcontainer-templates/`** — ready-made `devcontainer.json` configs you copy
   into projects. There is no inheritance in devcontainer.json, so each variant
   repeats the base features and adds its own on top.
2. **Dotfiles** (`install.sh`, `config/`, `shell/`) — DevPod clones this repo into
   every container and runs `install.sh`, which links `config/*` into `~/.config`
   and hooks `shell/*.sh` into `.bashrc`.

## Templates

| Template | Adds on top of base |
|---|---|
| `base/` | — (debian bookworm, python 3.12, node LTS, kubectl, helm, neovim) |
| `aws/` | aws-cli, terraform, `~/.aws` bind mount |
| `azure/` | azure-cli, `~/.azure` bind mount |
| `gcp/` | gcloud, `~/.config/gcloud` bind mount |
| `k8s-lab/` | docker-in-docker, kind — throwaway clusters for CKA practice |

## One-time setup

Point DevPod at this repo as your dotfiles source (applies to all workspaces):

```sh
devpod context set-options -o DOTFILES_URL=https://github.com/RitvikCS/devcon-dotfiles
```

## Using a template in a project

Copy the variant you want into the project:

```sh
mkdir -p myproject/.devcontainer
cp devcontainer-templates/aws/devcontainer.json myproject/.devcontainer/
devpod up ./myproject --ide none
devpod ssh myproject
```

A repo can also carry several configs side by side as
`.devcontainer/<name>/devcontainer.json`; pick one with
`devpod up . --devcontainer-path .devcontainer/<name>/devcontainer.json`.

## Notes

- First build of any template takes a few minutes (neovim compiles from
  source); rebuilds are cached.
- The cloud variants bind-mount host credential dirs — `mkdir -p` them on the
  host first or docker creates them root-owned.
- Node is installed via the official feature (nvm-based, version pinned in the
  json). fnm is deliberately not used: version switching per project is what
  containers already do.

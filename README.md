# ovnk-workspace

Multi-repo workspace for [OVN-Kubernetes](https://github.com/ovn-org/ovn-kubernetes) CI, AI, and docs automation.

## Setup

```bash
git clone https://github.com/dfarrell07/ovnk-workspace.git ~/ovnk
cd ~/ovnk
make clone-all
```

## Usage

```bash
make help        # list targets
make fetch       # git fetch all repos
make update      # fetch + fast-forward pull (skips non-default branches, dirty trees)
make clone-all   # clone any missing repos from repos.txt
make sync        # clone-all + regenerate .gitignore
make lint        # run linters
```

## Adding or removing repos

Edit `repos.txt` (one line per repo: `dirname url [path-override]`), then run `make sync`.

## Agent context

See [CLAUDE.md](CLAUDE.md) for AI agent orientation — repo map, CI systems, cross-repo dependencies, key people.

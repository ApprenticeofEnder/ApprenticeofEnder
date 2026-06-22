# Core

Personal Nix flake for Robert Babaev — declarative dotfiles + system config across macOS (nix-darwin), NixOS, and home-manager. Also the GitHub profile README repo.

## Memory graph (read in order of task)

- Stack, inputs, pkgs channels, caches: `mem:tech_stack`
- Module layout, import chain, autowiring patterns: `mem:architecture`
- home-manager module tree (programs, services, toolkits): `mem:home/core`
- AI coding tools (Claude/Cursor/OpenCode, MCP, agents, skills): `mem:home/ai-coding`
- Nix style, naming, auto-import, hooks: `mem:conventions`
- Dev/build/activate commands: `mem:suggested_commands`
- Pre-merge checklist: `mem:task_completion`

## Source map

```
flake.nix              → nixos-unified mkFlake; autowires modules/ + configurations/
configurations/        → machine entry points (darwin, nixos, home)
modules/               → reusable Nix modules (flake/, home/, darwin/, nixos/, shared/)
devenv.nix + .envrc    → repo dev shell, git hooks, scripts
justfile               → just run/update/check/lint/dev
dotfiles/              → stow-managed nvim + starship (git submodule for nvim)
templates/             → Jinja2 README generation
```

## Configurations (flake output names)

| Output | Name | Platform |
|--------|------|----------|
| darwinConfigurations | Roberts-Macbook-Air-2 | aarch64-darwin |
| nixosConfigurations | ender-raptor | Linux server |
| homeConfigurations | robertbabaev | macOS user |
| homeConfigurations | ender | generic Linux |
| homeConfigurations | ender@ender-hornet | Linux + ai-server toolkit |

Host-specific home configs use `configurations/home/<user>@<host>/default.nix` (not flat `.nix`).

## Invariants

- `pkgs` = nixos-unstable (primary); `pkgs-stable` = nixos-25.11 via `_module.args` in `modules/home/nix.nix`
- Toolkits in `modules/home/toolkits/` are **never** auto-imported — explicit per `configurations/home/*.nix`
- Secrets via Pulumi ESC (`ApprenticeofEnder/HomeBase/main@latest` in `.envrc`); never commit
- `.pre-commit-config.yaml` and `.devenv.flake.nix` are generated — do not edit
- README.md is generated — edit `templates/README.j2.md`, run `generate-readme`
- Cachix cache: `rbabaev`
- Custom `me.*` options (username, fullname, email) set per home config; used for git/HM identity
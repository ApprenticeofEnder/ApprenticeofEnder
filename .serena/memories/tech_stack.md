# Tech Stack

## Language & build

- **Nix** — entire config; formatter **Alejandra** (`nix fmt`, pre-commit)
- **Lix** as `nix.package` (via lix-module input)
- **flake-parts** + **nixos-unified** (srid) for modular flake + autowiring
- **devenv** for this repo's dev shell; **direnv** loads it via `.envrc`
- **just** task runner (`justfile`)
- **prek** runs git hooks (installed by devenv)

## System managers

- **home-manager** — user-level config (`modules/home/`)
- **nix-darwin** — macOS system (`modules/darwin/`)
- **NixOS** — Linux server (`modules/nixos/`, `configurations/nixos/ender-raptor/`)
- **nixvim** — Neovim config (`modules/home/programs/neovim/`); HM module also in system `sharedModules`

## nixpkgs channels

- `inputs.nixpkgs` → **nixos-unstable** (default `pkgs` everywhere)
- `inputs.nixpkgs-stable` → **nixos-25.11** (exposed as `pkgs-stable` in home modules)

## Flake inputs (beyond nixpkgs)

| Input                    | Use                                      |
| ------------------------ | ---------------------------------------- |
| nix-darwin, home-manager | System/user management                   |
| nixos-unified            | Autowiring                               |
| nur                      | Community packages                       |
| nix-index-database       | command-not-found                        |
| nixvim                   | Neovim HM module                         |
| Terramaid                | Terraform diagram overlay                |
| lix-module               | Lix nixos module                         |
| stylix                   | Theming (ender-raptor NixOS)             |
| elephant, walker         | Walker HM module (imported in `nix.nix`) |
| double-agent             | Custom input                             |
| obsidian-plugins         | Obsidian community plugins               |

## Cachix

Personal: `rbabaev`. Pulled in devenv: `nix-darwin`, `pre-commit-hooks`. Home config adds community caches (see `mem:architecture` → shared/nix settings).

## Dev shell tools (devenv.nix)

git, vale, just, nixd, stow, nix-top, prettier, jinja2-cli, pulumi-esc

## Lint/format (non-Nix)

- **Vale** — prose (`.vale.ini`, `styles/`)
- **Prettier** — markdown (README generation)
- **shellcheck** — shell scripts (excludes `.zsh`)
- **convco** — conventional commits (commit-msg hook)
- **deadnix** — unused Nix bindings
- **keep-sorted** — `keep-sorted start/end` list markers

## Dotfile hybrid

Most programs via home-manager; **nvim** and **starship** also stow-managed from `dotfiles/` (`dotfiles` script / manual stow).

## CI

No GitHub Actions. `vira.hs` defines Vira pipeline (builds x86_64-linux + aarch64-darwin).


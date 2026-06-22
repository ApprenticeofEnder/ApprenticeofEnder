# Suggested Commands

## just (task runner)

| Command | Runs |
|---------|------|
| `just` | List recipes |
| `just run` | `cachix watch-exec rbabaev -- nix run` |
| `just run-generic` | `cachix watch-exec rbabaev -- nix run '.#non-nixos'` |
| `just update` | `nix flake update` |
| `just lint` | `nix fmt .` |
| `just check` | `nix flake check` |
| `just dev` | `nix develop` |

## Nix / flake

| Command | Purpose |
|---------|---------|
| `nix run` | Activate config for current user/host |
| `nix run .#non-nixos` | Home config with user@host → user fallback |
| `nix run .#activate -- <ref>` | Explicit activation (hostname, user, user@host) |
| `nix run .#activate -- --dry-run <ref>` | Dry-run |
| `nix run .#update` | Update primary flake inputs |
| `nix flake check` | Evaluate configs/modules/packages |
| `nix flake check --all-systems` | All four supported systems |
| `nix fmt .` | Alejandra format |
| `nix develop` | Flake dev shell |
| `nix flake show` | List outputs |

Activation refs: `Roberts-Macbook-Air-2`, `ender-raptor`, `robertbabaev`, `ender`, `ender@ender-hornet`.

Darwin full system (not in justfile): `darwin-rebuild switch --flake .#Roberts-Macbook-Air-2`.

## devenv / direnv

Shell entry via `devenv shell` or direnv on `cd` (loads Pulumi ESC + devenv).

| Command | Purpose |
|---------|---------|
| `devenv test` | Verify git + pulumi-esc versions |
| `prek run --all-files` | Run all git hooks manually (inside devenv) |

## devenv scripts (in shell PATH)

| Command | Purpose |
|---------|---------|
| `upcache` | GC + push all store paths to Cachix `rbabaev` |
| `generate-readme` | Render `templates/README.j2.md` → `README.md` |
| `fetch-nvidia-drivers` | Prefetch NVIDIA driver hash into `modules/home/targets.nix` |
| `dotfiles` | Stow starship + nvim from `dotfiles/` into `$HOME` |

## Preferred CLI alternatives (configured in home)

| Instead of | Use |
|------------|-----|
| ls | eza |
| grep | rg |
| find | fd |
| cat | bat |
| top | btop |
| file browse | yazi |
| fuzzy find | television / fzf |
| nix search | nix-search-tv |
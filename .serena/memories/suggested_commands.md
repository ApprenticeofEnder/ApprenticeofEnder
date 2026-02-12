# Suggested Commands

## Task Runner (just)
| Command | Description |
|---------|-------------|
| `just` | List all available commands |
| `just run` | Activate the home-manager config for current user/host (`nix run`) |
| `just update` | Update all flake inputs (`nix flake update`) |
| `just lint` | Format all Nix files with Alejandra (`nix fmt .`) |
| `just check` | Run flake checks including pre-commit hooks (`nix flake check`) |
| `just dev` | Enter the development shell (`nix develop`) |

## devenv Scripts
| Command | Description |
|---------|-------------|
| `upcache` | Clean garbage + push to Cachix cache |
| `generate-readme` | Regenerate GitHub profile README from Jinja2 templates |
| `dotfiles` | Symlink dotfiles (starship, nvim) into home using GNU Stow |
| `nvidia-drivers` | Prefetch Nvidia driver hash for Nix |

## Testing
| Command | Description |
|---------|-------------|
| `devenv test` | Run test suite (verifies git version, pulumi-esc version) |

## Nix Commands
| Command | Description |
|---------|-------------|
| `nix run` | Activate home-manager config |
| `nix flake check` | Run flake checks |
| `nix flake update` | Update inputs |
| `nix fmt .` | Format with Alejandra |

## System Utils (Linux)
| Command | Description |
|---------|-------------|
| `git` | Version control |
| `ls` / `eza` | List files (eza is the preferred aliased version) |
| `grep` / `rg` | Search (ripgrep preferred) |
| `find` / `fd` | Find files (fd preferred) |
| `cat` / `bat` | View files (bat preferred) |

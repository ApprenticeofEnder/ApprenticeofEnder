# ApprenticeofEnder - Project Overview

## Purpose
Personal Nix-based system configuration repository for Robert Babaev (Security Software Engineer, Canada).
It serves as a unified, declarative dotfiles and system configuration that manages development environments,
system settings, packages, and tooling across multiple machines (NixOS/Linux and macOS/nix-darwin)
using a single Nix flake.

Also doubles as a GitHub profile README repo (`github.com/ApprenticeofEnder/ApprenticeofEnder`).

## Tech Stack
- **Language:** Nix (entire configuration is Nix expression language)
- **Nix Flake** as the top-level entry point
- **home-manager** for user-level configuration (follows nixpkgs)
- **nix-darwin** for macOS system-level settings (follows nixpkgs)
- **nixos-unified** (by srid) for autowiring flake outputs from `configurations/`
- **Lix** as the Nix package manager implementation (`nix.package = pkgs.lix`)
- **nixpkgs** (nixos-unstable as primary + nixos-25.11 as stable fallback)
- **devenv** for development shell management
- **Cachix** for binary caching (personal cache `rbabaev` + community caches: cachix, mfarabi, nixpkgs, oxalica, nix-darwin, nix-community, pre-commit-hooks)
- **NUR** (Nix User Repository) for additional community packages
- **flake-parts** for modular flake structure

## nixpkgs Channel Strategy (IMPORTANT)
- `pkgs` = nixos-unstable (primary, used for most packages)
- `pkgs-stable` = nixos-25.11 (stable fallback, available via `_module.args.pkgs-stable`)
- This is the REVERSE of what one might expect: unstable is the default.

## Supporting Tools
- **just** - task runner (justfile)
- **Vale** - prose linter (with proselint, write-good, and config styles)
- **Alejandra** - Nix code formatter
- **direnv** - automatic environment loading
- **GNU Stow** - dotfile symlinking (for nvim and starship)
- **Jinja2** (`jinja2-cli`) - README template generation
- **Prettier** - markdown formatting
- **Pulumi ESC** - secrets management
- **convco** - conventional commit enforcement
- **nixd** - Nix language server (in dev shell)
- **nix-top** - Nix build process viewer
- **Terramaid** - Terraform diagram generator (flake input, overlay)

## Multi-Machine Support
The activation system (`modules/flake/activate-home.nix`) tries `user@hostname` first,
then falls back to `user@`, enabling host-specific overrides.

### Machines
- `ender@ender-hornet` - Linux AI server, includes Ollama + CUDA, Rust, Python, JS toolkits
- `ender` - Generic Linux user, includes Rust, Python, JS toolkits
- `robertbabaev` - macOS user (includes darwin-only programs)
- `Roberts-Macbook-Air-2` - macOS system config (nix-darwin, aarch64-darwin)

## Key Software Inputs (flake.nix)
- `nixpkgs` (nixos-unstable) - primary
- `nixpkgs-stable` (nixos-25.11) - stable fallback
- `nix-darwin` - macOS system management
- `home-manager` - user config management
- `flake-parts` - modular flake outputs
- `nixos-unified` - autowiring
- `nur` - Nix User Repository
- `lix-module` - Lix package manager module
- `nix-index-database` - command-not-found database
- `Terramaid` - Terraform diagrams
- `nixvim` - (commented out, not currently active)

## Notable Program Configurations
- **1Password CLI** integration: `aws` and `gh` aliased through `op plugin run`
- **VS Code/VSCodium**: Enabled on Linux only (disabled on macOS due to C# intellisense issue)
- **Yazi**: File manager with extensive plugin ecosystem
- **Television + nix-search-tv**: Fuzzy finder with Nix package search integration
- **abcde**: CD ripper with udev rules, Fish functions, and ntfy push notifications
- **Ghostty**: Linux terminal emulator (Nord theme)
- **Kitty**: Cross-platform terminal (Nord theme)
- **Obsidian**: Declared but disabled by default

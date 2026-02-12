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
- **home-manager** (release-25.11) for user-level configuration
- **nix-darwin** (nix-darwin-25.11) for macOS system-level settings
- **nixos-unified** (by srid) for autowiring flake outputs from `configurations/`
- **Lix** as the Nix package manager implementation
- **nixpkgs** (nixos-25.11 stable + nixos-unstable for bleeding-edge packages)
- **devenv** for development shell management
- **Cachix** for binary caching (personal cache `rbabaev` + community caches)
- **NUR** (Nix User Repository) for additional community packages

## Supporting Tools
- **just** - task runner (justfile)
- **Vale** - prose linter (with proselint and write-good styles)
- **Alejandra** - Nix code formatter
- **direnv** - automatic environment loading
- **GNU Stow** - dotfile symlinking
- **Jinja2** - README template generation
- **Prettier** - markdown formatting
- **Pulumi ESC** - secrets management
- **convco** - conventional commit enforcement

## Multi-Machine Support
The activation system (`modules/flake/activate-home.nix`) tries `user@hostname` first,
then falls back to `user@`, enabling host-specific overrides.

### Machines
- `ender@ender-hornet` - Linux, includes AI server toolkit (Ollama + CUDA), Rust, Python, JS toolkits
- `ender` - Generic Linux user (no host-specific config)
- `robertbabaev` - macOS user (includes darwin-only programs)
- `Roberts-Macbook-Air-2` - macOS system config (nix-darwin)

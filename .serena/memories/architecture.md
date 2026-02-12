# Architectural Patterns

## 1. nixos-unified Autowiring
Uses `srid/nixos-unified` for flake structure. Configurations in `configurations/` are
automatically wired to flake outputs (`homeConfigurations`, `darwinConfigurations`).
File names in `configurations/home/` map to home-manager configuration names:
- `ender.nix` -> `homeConfigurations.ender@`
- `ender@ender-hornet.nix` -> `homeConfigurations.ender@ender-hornet`
- `robertbabaev.nix` -> `homeConfigurations.robertbabaev@`

## 2. Activation Fallback
`modules/flake/activate-home.nix` tries `user@hostname` first, falls back to `user@`.
This allows host-specific overrides while keeping a generic default.

## 3. Modular Auto-Import
Adding a new module is as simple as dropping a `.nix` file in the right directory.
The `default.nix` pattern auto-discovers and imports all siblings.

There are four variants of auto-import:
1. **Simple**: Import everything except `default.nix` (used in `modules/home/`, `linux-only/`, `darwin-only/`)
2. **Filtered**: Import everything except `default.nix` and named exclusions like `linux-only`/`darwin-only` dirs (used in `modules/home/programs/`)
3. **Filtered with backup exclusion**: Exclude backup files like `ntfy.bak.nix` (used in `modules/home/services/`)
4. **Empty/No-op**: `{}` -- requires explicit import (used in `modules/home/toolkits/`)

Exception: toolkits in `modules/home/toolkits/` are imported explicitly per-configuration.

## 4. Stable + Unstable nixpkgs
- `pkgs` = nixos-25.11 (stable)
- `pkgs-unstable` = nixos-unstable (for bleeding-edge: omnix, cachix, devenv, semgrep, ollama, opencode)

## 5. Custom `me` Option
`modules/home/me.nix` defines `me.username`, `me.fullname`, `me.email` options.
These are set in each configuration and used across git config, home-manager username, etc.

## 6. Platform Guards
- `lib.optionals stdenv.isLinux` / `stdenv.isDarwin` for conditional packages
- Separate directories for platform-specific programs (`linux-only/`, `darwin-only/`)
- Some programs use inline platform guards (e.g., `vscode.nix` disables VS Code on macOS)

## 7. README-as-Code
GitHub profile README generated from Jinja2 templates (`templates/README.j2.md`)
with data defined in `devenv.nix`. Auto-regenerated on shell entry when templates change.
Additional templates: `techtable.j2.html` for tech stack table, `readme.json` for data.

## 8. Secrets via Pulumi ESC
Loaded in `.envrc` from `ApprenticeofEnder/HomeBase/main@latest`. Never committed to repo.

## 9. 1Password CLI Plugin Integration
`modules/home/files/op.sh` aliases `aws` and `gh` to run through `op plugin run --`,
injecting credentials via 1Password CLI. Placed at `~/.config/op/plugins-nix.sh`.

## 10. myusers Auto-Discovery
`modules/darwin/common/myusers.nix` and `modules/nixos/common/myusers.nix` auto-discover
users from `configurations/home/` filenames. They create system user entries and wire up
home-manager for each user. The code is duplicated between darwin and nixos directories.

## 11. Configuration Hierarchy
```
flake.nix
  -> modules/flake/toplevel.nix (autowired, brings in nixos-unified)
  -> modules/flake/devshell.nix (autowired)
  -> modules/flake/activate-home.nix (autowired)
  -> configurations/darwin/Roberts-Macbook-Air-2.nix
       -> modules/darwin/default.nix (darwinModules.default)
            -> modules/darwin/common/myusers.nix
                 -> configurations/home/robertbabaev.nix
                      -> modules/home/default.nix (homeModules.default)
                           -> [all home modules auto-imported]
                      -> modules/home/programs/darwin-only/
  -> configurations/home/ender.nix (standalone home-manager)
       -> modules/home/default.nix (homeModules.default)
       -> modules/home/programs/linux-only/
       -> modules/home/toolkits/{rust,python,javascript}.nix
  -> configurations/home/ender@ender-hornet.nix (host-specific)
       -> [same as ender.nix] + modules/home/toolkits/ai-server.nix
```

## 12. Dotfile Hybrid Approach
Some dotfiles are managed via home-manager (most programs), while nvim and starship configs
are managed via GNU Stow from `dotfiles/` directory. This is a deliberate hybrid approach.

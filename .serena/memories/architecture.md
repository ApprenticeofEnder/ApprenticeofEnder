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

## 7. README-as-Code
GitHub profile README generated from Jinja2 templates (`templates/README.j2.md`)
with data defined in `devenv.nix`. Auto-regenerated on shell entry when templates change.

## 8. Secrets via Pulumi ESC
Loaded in `.envrc` from `ApprenticeofEnder/HomeBase/main@latest`. Never committed to repo.

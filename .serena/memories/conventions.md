# Conventions

## Nix style

- Formatter: **Alejandra** only (not nixfmt)
- Function args: `{ lib, pkgs, config, flake, ... }:`
- Packages: `with pkgs; [ ... ]`; stable via `pkgs-stable.*`
- Local bindings: `let ... in`
- Inline `#` comments on package entries

## Naming

- Files: lowercase-with-hyphens (`nix-index.nix`, `ai-server.nix`)
- Directories: `default.nix` entry point
- HM options: camelCase
- Custom identity: `me.{username,fullname,email}`
- Disabled/backup modules: `.bak.nix` suffix (excluded from auto-import)

## Auto-import pattern

```nix
imports = with builtins;
  map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));
```

Variations documented in `mem:architecture`.

## Sorted lists

Use `keep-sorted start` / `keep-sorted end` markers as comments; enforced by pre-commit `keep-sorted` hook. Used wherever multiple items need to be sorted in alphabetical order.

## Module organization

- Simple config → single file (`program.nix`)
- Complex config → directory (`program/default.nix` + themes/scripts)
- Platform-specific → `linux-only/` or `darwin-only/` subdirs
- Package grouping in `packages.nix`: named `let` bindings (dev, security, devops, …)

## Commits

Conventional commits enforced by `convco` (commit-msg hook): `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, etc.

## Generated files — do not edit

- `.pre-commit-config.yaml` (from devenv git-hooks.nix)
- `.devenv.flake.nix` (from devenv)
- Root `README.md` (from templates via `generate-readme`)

## Secrets

Never commit. Pulumi ESC loaded in `.envrc`.


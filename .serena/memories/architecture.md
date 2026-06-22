# Architecture

## nixos-unified autowiring

`flake.nix` → `inputs.nixos-unified.lib.mkFlake { root = ./.; }`. Scans `modules/` and `configurations/` to export:

- `homeModules.default` ← `modules/home/default.nix`
- `darwinModules.{default,_1password}` ← `modules/darwin/`
- `nixosModules.{default,common,_1password}` ← `modules/nixos/`
- `*Configurations.*` ← `configurations/{home,darwin,nixos}/`

`modules/flake/toplevel.nix`: alejandra formatter, `packages.default = activate`.

## Activation

`modules/flake/activate-home.nix`: tries `user@hostname` first, falls back to `user@`.

| Command | Behavior |
|---------|----------|
| `nix run` / `just run` | Default activate (Cachix-wrapped in just) |
| `nix run .#non-nixos` / `just run-generic` | Home-only with host fallback |
| `nix run .#activate -- <ref>` | Explicit ref (hostname, user, or user@host) |

## myusers auto-discovery

`modules/darwin/common/myusers.nix` and `modules/nixos/common/myusers.nix` (duplicated):
- Discover users from `configurations/home/` filenames
- Create system user entries
- Wire `home-manager.users.<name>.imports = [ configurations/home/<name>.nix ]`

## Modular auto-import

Four variants:

1. **Simple** — all siblings except `default.nix` (`modules/home/`, `linux-only/`, `darwin-only/`)
2. **Filtered** — excludes platform subdirs (`modules/home/programs/default.nix`)
3. **Backup-filtered** — excludes `.bak.nix` and named files (`modules/home/services/default.nix` excludes `ntfy.bak.nix`, `ssh-agent.nix`)
4. **Empty/no-op** — `{}` in `modules/home/toolkits/`; explicit import only

**Exception:** `ai-coding/default.nix` uses explicit sorted imports, not auto-import.

## Configuration hierarchy

```
flake.nix → nixos-unified autowire
  configurations/darwin/Roberts-Macbook-Air-2.nix
    → darwinModules → myusers → configurations/home/robertbabaev.nix
      → homeModules.default + programs/darwin-only + toolkits
  configurations/nixos/ender-raptor/
    → nixosModules + stylix + home-manager.sharedModules (nixvim, linux-only)
  configurations/home/ender.nix
    → homeModules.default + programs/linux-only + toolkits
  configurations/home/ender@ender-hornet/default.nix
    → same + ai-server toolkit
```

## Per-user config pattern

```nix
imports = [ self.homeModules.default ]
  ++ importHome "programs" [ "linux-only" ]  # or "darwin-only"
  ++ importHome "toolkits" [ "rust.nix" "python.nix" "javascript.nix" ];
me = { username = "..."; fullname = "..."; email = "..."; };
```

## Platform guards

- `lib.optionals stdenv.isLinux/isDarwin` in package lists
- `programs/linux-only/` and `programs/darwin-only/` subdirs
- VS Code disabled on macOS (C# intellisense issue)

## Shared Nix settings

`modules/shared/nix/` — binary cache substituters/trusted keys; imported from `modules/home/home.nix`.

## Secrets & credentials

- Pulumi ESC in `.envrc`
- 1Password CLI: `modules/home/files/op.sh` aliases `aws`/`gh` through `op plugin run`
- `_1password` modules in darwin/nixos for system-level 1Password integration

## README-as-code

Jinja2 templates in `templates/`; `generate-readme` script renders `README.j2.md` + `readme.json` → `README.md`.
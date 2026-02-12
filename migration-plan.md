## Assistant (Plan · claude-opus-4.6 · 26.4s)

Now I have the complete picture. Here's the refined, final plan:

---

## Final Execution Plan: Migrate to nixpkgs-unstable as Default

### Step 1: Update `flake.nix` (6 changes)

| Change                | Before                                                         | After                                                     |
| --------------------- | -------------------------------------------------------------- | --------------------------------------------------------- |
| Primary nixpkgs       | `nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"`             | `nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"`     |
| Stable fallback       | `nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"` | `nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11"` |
| home-manager branch   | `url = "github:nix-community/home-manager/release-25.11"`      | `url = "github:nix-community/home-manager"` (master)      |
| home-manager follows  | `inputs.nixpkgs.follows = "nixpkgs-unstable"`                  | `inputs.nixpkgs.follows = "nixpkgs"`                      |
| nix-darwin branch     | `url = "github:nix-darwin/nix-darwin/nix-darwin-25.11"`        | `url = "github:nix-darwin/nix-darwin"` (master)           |
| Remove inetutils TODO | Lines 14-16 comment                                            | Delete                                                    |

Inputs that currently `follows = "nixpkgs"` (`nur`, `lix-module`, `nix-index-database`) need **no changes** - they'll automatically follow the new unstable nixpkgs since the name `nixpkgs` doesn't change.

### Step 2: Rewrite `modules/home/nix.nix`

- Rename `pkgs-unstable` -> `pkgs-stable`, importing from `flake.inputs.nixpkgs-stable`
- Change `_module.args.pkgs-unstable` -> `_module.args.pkgs-stable`
- **Remove the inetutils overlay entirely** - since `pkgs` will now be unstable (which has the working inetutils 2.6), the macOS workaround is no longer needed

### Step 3: Rewrite `configurations/darwin/Roberts-Macbook-Air-2.nix`

- Remove the separate `pkgs-unstable` import (lines 10-13)
- Remove the inetutils overlay (lines 21-27)
- Remove `pkgs` from the function args if it's no longer needed for the overlay

### Step 4: Update package references across 4 files

| File                                   | Change                                                                                                                       |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `modules/home/packages.nix`            | Remove `pkgs-unstable` arg; fold `pkgs-unstable.omnix/cachix/devenv/semgrep` into their respective `with pkgs` blocks        |
| `modules/home/programs/opencode.nix`   | Change arg from `pkgs-unstable` to `pkgs`; remove `package = pkgs-unstable.opencode` since it will be in unstable by default |
| `configurations/home/robertbabaev.nix` | Remove `pkgs-unstable` arg; change `${pkgs-unstable.opencode}` to `${pkgs.opencode}`                                         |
| `modules/home/toolkits/ai-server.nix`  | Remove `pkgs-unstable` arg; change `pkgs-unstable.ollama` to `pkgs.ollama` (2 occurrences)                                   |

### Step 5: Update flake lock

Run `nix flake update` to re-pin all inputs to the new branches.

### Step 6: Validate build (no activation)

Build each configuration without activating:

```
nix build .#homeConfigurations."ender@ender-hornet".activationPackage
nix build .#homeConfigurations."ender@".activationPackage
```

(macOS configs can't be built on Linux, so those would need testing on the Mac)

If any packages fail to build on unstable, pin them to `pkgs-stable` as needed.

### Step 7: Activate and smoke-test

Run `nix run` to activate. Watch for:

- File collision warnings from home-manager
- Missing/renamed module options (unstable HM master may have different options than release-25.11)
- Packages that work differently on newer versions

### Step 8: Cleanup

- Remove stale TODO comments about inetutils
- Update Serena memory files (`architecture.md`, `project_overview.md`) to reflect the new setup

---

### Files touched (summary)

1. `flake.nix` - swap inputs
2. `modules/home/nix.nix` - invert stable/unstable, remove inetutils overlay
3. `configurations/darwin/Roberts-Macbook-Air-2.nix` - remove overlay and pkgs-unstable import
4. `modules/home/packages.nix` - remove pkgs-unstable references
5. `modules/home/programs/opencode.nix` - use pkgs instead of pkgs-unstable
6. `configurations/home/robertbabaev.nix` - use pkgs instead of pkgs-unstable
7. `modules/home/toolkits/ai-server.nix` - use pkgs instead of pkgs-unstable

### State version note

`home.stateVersion = "25.05"` stays exactly as-is in all three home configurations. `system.stateVersion = 4` stays in the darwin config. These are backwards-compatibility markers, not version trackers. If anything breaks post-migration, the fix is pinning the offending package to `pkgs-stable`, never changing stateVersion.

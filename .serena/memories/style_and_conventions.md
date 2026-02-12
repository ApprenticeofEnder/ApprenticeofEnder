# Code Style and Conventions

## Language
- All configuration is written in the **Nix expression language**.
- The Nix formatter is **Alejandra** (enforced via pre-commit hook and `nix fmt`).

## Naming Conventions
- File names: lowercase with hyphens (e.g., `nix-index.nix`, `ai-server.nix`)
- Directory-based modules use `default.nix` as entry point
- Configuration options use camelCase (standard Nix/home-manager convention)
- Custom options under `me.*` (username, fullname, email)

## Module Organization Patterns
1. **Auto-import pattern:** `default.nix` files auto-import all sibling `.nix` files using:
   ```nix
   imports = with builtins;
     map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));
   ```
   Used in: `modules/home/`, `modules/home/programs/linux-only/`, `modules/home/programs/darwin-only/`

2. **Filtered auto-import:** `modules/home/programs/default.nix` excludes `linux-only` and `darwin-only` dirs.

3. **Backup-filtered auto-import:** `modules/home/services/default.nix` excludes `.bak.nix` files.

4. **Toolkits are NOT auto-imported:** `modules/home/toolkits/default.nix` is empty (`{}`).
   Toolkits are explicitly imported per-configuration in `configurations/home/*.nix`.

5. **Platform-conditional code:**
   - Platform-specific programs in `programs/linux-only/` and `programs/darwin-only/`
   - Package lists use `lib.optionals stdenv.isLinux` / `stdenv.isDarwin` guards
   - Some programs use inline guards (e.g., `vscode.nix` disables on macOS)

6. **Package grouping in packages.nix:** Packages organized into named `let` bindings:
   `dev`, `security`, `devops`, `utility`, `linux`, `x86Linux`, `darwin`, `fun`

## Module Types
- **`modules/home/`** - Auto-imported into all home-manager configs
- **`modules/home/programs/`** - Individual program configs (auto-imported)
- **`modules/home/services/`** - systemd/launchd services (auto-imported)
- **`modules/home/scripts/`** - Custom shell scripts built via `writeShellScriptBin`
- **`modules/home/files/`** - Static files placed via `home.file`
- **`modules/home/toolkits/`** - Language toolkits (explicitly imported per-config)

## Nix Style
- Function arguments use the `{ arg1, arg2, ... }:` pattern
- `let ... in` blocks for local bindings
- `with pkgs;` for package lists to avoid repetitive `pkgs.` prefixes
- Inline comments with `#` to describe individual packages
- `pkgs-stable.*` for stable packages (primary is unstable)
- Overlays defined in `modules/home/nix.nix` (e.g., Terramaid)

## Commit Conventions
- **Conventional commits** enforced via `convco` pre-commit hook
- Prefixes: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, etc.

## Pre-commit Hooks
1. **alejandra** - Nix formatting (on `.nix` files)
2. **deadnix** - Dead Nix code detection (on `.nix` files)
3. **vale** - Prose linting (on text files)
4. **shellcheck** - Shell script linting (excludes `.zsh` files)
5. **convco** - Conventional commit message validation (on commit-msg stage)

## Configuration File Conventions
- Programs with complex config use directory format: `program-name/default.nix` + supporting files
- Programs with simple config use single file: `program-name.nix`
- Theme files, config files, and shell scripts live alongside their `default.nix`
- `.bak.nix` suffix for backup/disabled module files (auto-excluded from imports)

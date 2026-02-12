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
   Used in: `modules/home/`, `modules/home/programs/`, `modules/home/services/`

2. **Toolkits are NOT auto-imported:** `modules/home/toolkits/default.nix` is empty.
   Toolkits are explicitly imported per-configuration in `configurations/home/*.nix`.

3. **Platform-conditional code:**
   - Platform-specific programs in `programs/linux-only/` and `programs/darwin-only/`
   - Package lists use `lib.optionals stdenv.isLinux` / `stdenv.isDarwin` guards

4. **Package grouping in packages.nix:** Packages organized into named `let` bindings:
   `dev`, `security`, `devops`, `utility`, `linux`, `x86Linux`, `darwin`, `fun`

## Nix Style
- Function arguments use the `{ arg1, arg2, ... }:` pattern
- `let ... in` blocks for local bindings
- `with pkgs;` for package lists to avoid repetitive `pkgs.` prefixes
- Inline comments with `#` to describe individual packages
- `pkgs-unstable.*` for bleeding-edge packages

## Commit Conventions
- **Conventional commits** enforced via `convco` pre-commit hook
- Prefixes: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, etc.

## Pre-commit Hooks
1. **alejandra** - Nix formatting (on `.nix` files)
2. **deadnix** - Dead Nix code detection (on `.nix` files)
3. **vale** - Prose linting (on text files)
4. **shellcheck** - Shell script linting (excludes `.zsh` files)
5. **convco** - Conventional commit message validation (on commit-msg stage)

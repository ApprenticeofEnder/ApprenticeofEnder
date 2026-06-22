# Task Completion

Run before considering a Nix/config change done:

## 1. Format

```bash
nix fmt .    # or: just lint
```

Alejandra; also runs on pre-commit for `.nix` files.

## 2. Flake check

```bash
nix flake check    # or: just check
```

Evaluates NixOS/darwin/home configs and packages. **Does not run pre-commit hooks** (`checks.*` outputs are empty).

## 3. Pre-commit hooks (manual if needed)

Hooks run automatically on commit inside devenv shell. Manual run:

```bash
prek run --all-files
```

Hooks: alejandra, deadnix, keep-sorted, shellcheck (excludes `.zsh`), vale (prose), convco (commit-msg).

## 4. devenv test (optional)

```bash
devenv test
```

Checks git + pulumi-esc versions.

## 5. Activate (if home/system modules changed)

```bash
nix run    # or: just run
```

Builds and applies home-manager / nix-darwin / NixOS config.

## 6. Commit

Conventional commit message (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`). Enforced by convco on commit-msg.

## Common pitfalls

- Edit `templates/README.j2.md`, not root `README.md`; then `generate-readme`
- New toolkit → explicit import in `configurations/home/*.nix`
- New service → auto-imported unless `.bak.nix`
- Do not edit `.pre-commit-config.yaml` or `.devenv.flake.nix`
- Never commit secrets (Pulumi ESC handles runtime secrets)
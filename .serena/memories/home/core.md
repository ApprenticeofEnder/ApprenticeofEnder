# home-manager Modules

Entry: `modules/home/default.nix` (auto-imports siblings; excludes `targets.nix`, `drivers.json`).

## Top-level home modules

| Module | Role |
|--------|------|
| me.nix | Custom `me.{username,fullname,email}` options |
| nix.nix | Lix, pkgs-stable passthrough, walker HM import |
| packages.nix | Grouped packages: dev, security, devops, utility, linux, x86Linux, darwin, fun |
| home.nix | Base home config, imports shared/nix |
| git.nix, shell.nix, fonts.nix, direnv.nix, nix-index.nix, gc.nix | Standard HM config |

## programs/ (auto-imported)

Individual program configs. Excludes `linux-only/` and `darwin-only/` dirs (imported per-config).

Notable subsystems:
- **ai-coding/** — see `mem:home/ai-coding`
- **neovim/** — nixvim-based; plugins auto-imported; also stow dotfile
- Shell/terminal: fish, zsh, kitty, fastfetch, btop
- TUI: yazi, television, lazygit, lazydocker, lazysql, spotify-player
- Security: ssh, gpg, rbw, password-store, netbird

Legacy stub: `programs/opencode/default.nix` (commented out) — superseded by `ai-coding/opencode/`.

## services/ (auto-imported)

systemd/launchd user services. Excludes `ntfy.bak.nix`, `ssh-agent.nix`.
Examples: gpg-agent, spotifyd (Linux), redshift (Linux), podman (Linux), tldr, remmina.

## toolkits/ (NOT auto-imported)

Explicit import per `configurations/home/*.nix`:

| File | Contents |
|------|----------|
| rust.nix | cargo, rust-analyzer, rustfmt, cargo-binstall, cargo-seek |
| python.nix | python313, ruff, uv |
| javascript.nix | nodejs_24, pnpm, biome |
| ai-server.nix | Ollama (CUDA), mlx-lm, model pulls; OpenCode ollama-ender provider |

Typical assignments:
- ender → rust, python, javascript
- robertbabaev → rust, javascript (via darwin sharedModules)
- ender@ender-hornet → all four including ai-server

## scripts/ and files/

- `scripts/` — `writeShellScriptBin` custom commands (yls, fit)
- `files/` — static assets via `home.file` (e.g. op.sh for 1Password)

## Adding new modules

- New program: drop `.nix` or `program/default.nix` in `programs/` (auto-imported)
- New service: drop in `services/` (auto-imported unless `.bak.nix`)
- New toolkit: add to `toolkits/`, **explicitly import** in relevant home config
- Platform-specific: `linux-only/` or `darwin-only/`, import via `importHome "programs" [...]`
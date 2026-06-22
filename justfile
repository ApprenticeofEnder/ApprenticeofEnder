# Like GNU `make`, but `just` rustier.
# https://just.systems/
# run `just` from this directory to see available commands

# Default command when 'just' is run without arguments
default:
  @just --list

# Update nix flake
[group('Main')]
update:
  nix flake update

# Lint nix files
[group('dev')]
lint:
  nix fmt .

# Check nix flake
[group('dev')]
check:
  nix flake check

# Manually enter dev shell
[group('dev')]
dev:
  nix develop

[group('dev')]
nvim:
  nix run .#nvim -- .

[group('dev')]
nvim-check:
  #!/usr/bin/env bash
  arch=$(uname -m)
  [[ "$arch" == "arm64" ]] && arch=aarch64
  os=$([[ "$(uname -s)" == "Darwin" ]] && echo darwin || echo linux)
  nix build ".#checks.${arch}-${os}.nixvim"

# Activate the configuration
[group('Main')]
run:
  cachix watch-exec rbabaev -- nix run

# Activate the configuration (non-NixOS)
[group('Main')]
run-generic:
  cachix watch-exec rbabaev -- nix run '.#non-nixos'

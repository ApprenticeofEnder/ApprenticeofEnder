# See /modules/darwin/* for actual settings
# This file is just *top-level* configuration.
{
  flake,
  pkgs,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in {
  imports = [
    self.darwinModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # inetutils 2.7 in nixos-25.11 fails to build on macOS due to gnulib/clang incompatibility.
  # Use inetutils from unstable (2.6) which builds fine.
  nixpkgs.overlays = [
    (_final: _prev: {
      inetutils = pkgs-unstable.inetutils;
    })
  ];
  networking.hostName = "Roberts-Macbook-Air-2";

  system.primaryUser = "robertbabaev";

  # Automatically move old dotfiles out of the way
  #
  # Note that home-manager is not very smart, if this backup file already exists it
  # will complain "Existing file .. would be clobbered by backing up". To mitigate this,
  # we try to use as unique a backup file extension as possible.
  home-manager.backupFileExtension = "nixos-unified-template-backup";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}

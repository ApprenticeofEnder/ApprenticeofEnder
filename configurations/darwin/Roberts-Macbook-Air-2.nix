# See /modules/darwin/* for actual settings
# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.darwinModules.default
  ];

  # HACK: There has to be a more modular way of doing this right?
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
    };

    overlays = [
      (_: prev: {
        terramaid = flake.inputs.Terramaid.packages.${prev.stdenv.hostPlatform.system}.default;
      })
    ];
  };

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

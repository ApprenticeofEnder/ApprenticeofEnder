# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (inputs) nixvim;
  inherit (inputs) stylix;
  homeMod = self + /modules/home;
in {
  imports = [
    self.nixosModules.default
    stylix.nixosModules.stylix
    ./configuration.nix
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  home-manager.sharedModules = [
    nixvim.homeModules.default
    "${homeMod}/programs/linux-only"
  ];

  programs.nix-ld.enable = true;

  # Automatically move old dotfiles out of the way
  #
  # Note that home-manager is not very smart, if this backup file already exists it
  # will complain "Existing file .. would be clobbered by backing up". To mitigate this,
  # we try to use as unique a backup file extension as possible.
  home-manager.backupFileExtension = "nixos-unified-template-backup";

  # TODO: Stylix!

  myusers = ["ender"];
}

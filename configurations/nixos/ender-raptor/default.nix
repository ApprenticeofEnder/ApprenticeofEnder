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
    self.nixosModules._1password
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

  # TODO: Stylix!

  myusers = ["ender"];
}

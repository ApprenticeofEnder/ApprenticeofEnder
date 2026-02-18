# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in {
  imports = [
    self.nixosModules.default
    self.nixosModules._1password
    ./configuration.nix
  ];

  home-manager.sharedModules = [
    "${homeMod}/programs/linux-only"
  ];

  myusers = ["ender"];
}

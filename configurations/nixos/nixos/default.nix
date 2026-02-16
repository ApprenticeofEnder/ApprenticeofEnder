# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in {
  imports = [
    self.nixosModules.default
    ./configuration.nix
  ];

  home-manager.sharedModules = [
    "${homeMod}/programs"
    "${homeMod}/direnv.nix"
    "${homeMod}/fonts.nix"
    "${homeMod}/gc.nix"
    "${homeMod}/git.nix"
    "${homeMod}/home.nix"
    "${homeMod}/nix-index.nix"
    "${homeMod}/nix.nix"
    "${homeMod}/packages.nix"
    "${homeMod}/shell.nix"
  ];
}

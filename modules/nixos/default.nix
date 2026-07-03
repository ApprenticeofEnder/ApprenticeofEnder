# This is your nixos configuration.
# For home configuration, see /modules/home/*
{
  flake,
  lib,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  shared-lib = import (self + /shared/lib) {inherit lib;};
in {
  imports =
    [
      self.nixosModules.common
    ]
    ++ shared-lib.getNixImports {
      root = ./.;
      exclude = ["common/*"];
    };
  services.openssh.enable = true;
}

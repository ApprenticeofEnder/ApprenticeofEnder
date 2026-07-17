{
  flake,
  lib,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  shared-lib = import (self + /modules/shared/lib) {
    inherit lib;
    globset = inputs.globset;
  };
in {
  imports = shared-lib.getNixImports {
    root = ./.;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
}

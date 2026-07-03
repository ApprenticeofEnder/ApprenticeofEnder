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

  terramaidOverlay = _: prev: let
    system = prev.stdenv.hostPlatform.system;
  in {
    terramaid = flake.inputs.Terramaid.packages.${system}.default;
  };
in {
  imports = shared-lib.getNixImports {
    root = ./.;
  };

  nixpkgs.overlays = [
    terramaidOverlay
    (_: prev: {
      direnv = prev.direnv.overrideAttrs (_: {
        doCheck = false;
      });
    })
    flake.inputs.obsidian-plugins.overlays.default
  ];
}

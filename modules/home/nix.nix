{
  config,
  pkgs,
  lib,
  flake,
  ...
}: let
  pkgs-stable = import flake.inputs.nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  # Make pkgs-stable available to all modules
  _module.args.pkgs-stable = pkgs-stable;

  # `nix.package` is already set if on `NixOS` or `nix-darwin`.
  # TODO: Avoid setting `nix.package` in two places. Does https://github.com/juspay/nixos-unified-template/issues/93 help here?
  nix.package = lib.mkDefault pkgs.lix;
  home.packages = [config.nix.package];

  imports = [flake.inputs.walker.homeManagerModules.default];
  nixpkgs = {
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };

    overlays = [
      (_: prev: {
        terramaid = flake.inputs.Terramaid.packages.${prev.stdenv.hostPlatform.system}.default;
      })
    ];
  };
}

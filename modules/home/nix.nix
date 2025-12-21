{
  config,
  pkgs,
  lib,
  flake,
  ...
}: let
  pkgs-unstable = import flake.inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };
in {
  # Make pkgs-unstable available to all modules
  _module.args.pkgs-unstable = pkgs-unstable;

  # `nix.package` is already set if on `NixOS` or `nix-darwin`.
  # TODO: Avoid setting `nix.package` in two places. Does https://github.com/juspay/nixos-unified-template/issues/93 help here?
  nix.package = lib.mkDefault pkgs.lix;
  home.packages = [config.nix.package];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    nvidia.acceptLicense = true;
  };
}

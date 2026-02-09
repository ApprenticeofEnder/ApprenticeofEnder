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

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      nvidia.acceptLicense = true;
    };

    overlays = [
      (_: prev: {
        terramaid = flake.inputs.Terramaid.packages.${prev.stdenv.hostPlatform.system}.default;
      })
      # inetutils 2.7 in nixos-25.11 fails to build on macOS due to gnulib/clang incompatibility.
      # Use inetutils from unstable (2.6) which builds fine.
      (_: prev:
        lib.optionalAttrs prev.stdenv.isDarwin {
          inetutils = pkgs-unstable.inetutils;
        })
    ];
  };
}

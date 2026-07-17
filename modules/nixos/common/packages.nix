{
  flake,
  pkgs,
  lib,
  ...
}: let
  terramaidOverlay = _: prev: let
    system = prev.stdenv.hostPlatform.system;
  in {
    terramaid = flake.inputs.Terramaid.packages.${system}.default;
  };

  direnvOverlay = _: prev: {
    direnv = prev.direnv.overrideAttrs (_: {
      doCheck = false;
    });
  };
in {
  nix.package = pkgs.lix;

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      terramaidOverlay
      direnvOverlay
      flake.inputs.obsidian-plugins.overlays.default
    ];
  };
  environment.systemPackages = with pkgs;
    [
      openssl
    ]
    ++ lib.optionals (pkgs.stdenv.isLinux) [
      proton-vpn
    ];
}

{
  flake,
  pkgs,
  lib,
  ...
}: let
  pkgs-stable = import flake.inputs.nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
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
  nix.package = pkgs-stable.lix;

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
    ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux) [
      proton-vpn
    ];
}

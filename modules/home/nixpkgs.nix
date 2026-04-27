{
  flake,
  lib,
  osConfig,
  ...
}: let
  terramaidOverlay = _: prev: let
    system = prev.stdenv.hostPlatform.system;
  in {
    terramaid = flake.inputs.Terramaid.packages.${system}.default;
  };
in {
  nixpkgs = lib.mkIf (osConfig == null) {
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };

    overlays = [
      terramaidOverlay
      flake.inputs.obsidian-plugins.overlays.default
    ];
  };
}

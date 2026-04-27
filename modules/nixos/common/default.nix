{flake, ...}: let
  terramaidOverlay = _: prev: let
    system = prev.stdenv.hostPlatform.system;
  in {
    terramaid = flake.inputs.Terramaid.packages.${system}.default;
  };
in {
  imports = [
    ./myusers.nix
    ./packages.nix
  ];
  nixpkgs.overlays = [
    terramaidOverlay
  ];
}

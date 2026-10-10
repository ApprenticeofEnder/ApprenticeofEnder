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
  podmanOverlay = _: prev: {
    podman = prev.podman.overrideAttrs (
      _: let
        version = "5.8.4";
      in {
        version = version;
        src = prev.fetchFromGitHub {
          owner = "podman-container-tools";
          repo = "podman";
          tag = "v${version}";
          hash = "sha256-zhEtMZVKiv1L72EMlwgz8sHpmvhejGp98oW63aPj+rQ=";
        };
        doInstallCheck = false;
      }
    );
  };
in {
  nixpkgs = lib.mkIf (osConfig == null) {
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };

    overlays = [
      terramaidOverlay
      podmanOverlay
      flake.inputs.obsidian-plugins.overlays.default
    ];
  };
}

{
  flake,
  lib,
  osConfig,
  ...
}: {
  nixpkgs = lib.mkIf (osConfig == null) {
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

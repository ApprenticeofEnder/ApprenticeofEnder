{flake, ...}: {
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

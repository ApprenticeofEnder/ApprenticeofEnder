{inputs, ...}: {
  perSystem = {
    system,
    lib,
    ...
  }: let
    nixvim = inputs.nixvim.legacyPackages.${system};

    pkgsUnfree = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    nvim = nixvim.makeNixvimWithModule {
      pkgs = pkgsUnfree;
      module = import ../../modules/home/programs/neovim/nixvim-config.nix;
    };
  in {
    packages.nvim = nvim;

    apps.nvim = {
      type = "app";
      program = lib.getExe nvim;
    };

    checks.nixvim = nvim.config.build.test;
  };
}

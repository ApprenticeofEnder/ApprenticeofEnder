{ pkgs, lib, ... }: {
  targets = {
    genericLinux = lib.mkIf pkgs.stdenv.isLinux {
      gpu.nvidia.enable = true;
    };
  };
}

{pkgs, ...}: {
  services.protonmail-bridge = {
    enable = pkgs.stdenv.isLinux;
  };
}

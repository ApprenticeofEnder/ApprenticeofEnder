{pkgs, ...}: {
  services.protonmail-bridge = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}

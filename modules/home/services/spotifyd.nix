{pkgs, ...}: {
  services.spotifyd = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}

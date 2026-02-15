{pkgs, ...}: {
  services.walker = {
    enable = pkgs.stdenv.isLinux;
  };
}

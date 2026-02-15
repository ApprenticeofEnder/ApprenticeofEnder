{pkgs, ...}: {
  programs.walker.enable = pkgs.stdenv.isLinux;
}

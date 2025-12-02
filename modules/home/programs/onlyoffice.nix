{ pkgs, ... }: {
  programs.onlyoffice.enable = pkgs.stdenv.isLinux;
}

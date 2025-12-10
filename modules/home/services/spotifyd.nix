{ pkgs, ... }:
{
  services.spotifyd = {
    enable = pkgs.stdenv.isLinux;
  };
}

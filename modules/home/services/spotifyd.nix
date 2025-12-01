{ pkgs
, config
, lib
, ...
}:
{
  services.spotifyd = {
    enable = pkgs.stdenv.isLinux;
  };
}

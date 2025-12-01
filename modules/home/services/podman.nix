{ pkgs, ... }:
{
  services.podman = {
    enable = pkgs.stdenv.isLinux;
    enableTypeChecks = true;
    autoUpdate.enable = true;
  };
}

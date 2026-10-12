{
  pkgs,
  lib,
  ...
}: let
  sockets = {
    podman = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    podmanRoot = "unix:///run/podman/podman.sock";
    docker = "unix:///var/run/docker.sock";
  };
  lazydockerBin = lib.getExe pkgs.lazydocker;
in {
  home.shellAliases = {
    lzp = ''DOCKER_HOST="${sockets.podman}" ${lazydockerBin}'';
    lzpr = ''DOCKER_HOST="${sockets.podmanRoot}" sudo ${lazydockerBin}'';
    lzd = ''DOCKER_HOST=${sockets.docker} ${lazydockerBin}'';
  };
  programs.lazydocker = {
    enable = true;
    settings = {
    };
  };
}

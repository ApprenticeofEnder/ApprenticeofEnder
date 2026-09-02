{pkgs, ...}: {
  home.sessionVariables = {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
  };
  services.podman = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    enableTypeChecks = true;
    autoUpdate.enable = true;
  };
}

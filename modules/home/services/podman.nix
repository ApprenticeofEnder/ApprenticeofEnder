{pkgs, ...}: {
  services.podman = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    enableTypeChecks = true;
    autoUpdate.enable = true;
  };
}

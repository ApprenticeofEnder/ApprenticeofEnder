{
  lib,
  pkgs,
  nixosConfig,
  ...
}: {
  services.ssh-agent = lib.mkIf pkgs.stdenv.isLinux {
    enable = nixosConfig == null;
    # forwardAgent = false;
    # socket = "ssh-agent"; # default
  };
}

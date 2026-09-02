{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.podman;
in {
  options.podman = {
    enable = mkEnableOption "Podman";
    # keep-sorted start block=yes newline_separated=yes
    dockerHost = mkOption {
      type = types.str;
      default = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    };
    # keep-sorted end
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      DOCKER_HOST = cfg.dockerHost;
    };
    services.podman = {
      enable = true;
      enableTypeChecks = true;
      autoUpdate.enable = true;
      settings = {
        containers = {
          containers = {
            pids_limit = 65536;
          };
        };
      };
    };
  };
}

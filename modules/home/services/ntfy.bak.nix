{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.ntfy-client;

  mkSubscription = sub: {
    topic = sub.topic;
    command = sub.command or ''notify-send "''${NTFY_TITLE:-ntfy}" "''${NTFY_MESSAGE}"'';
    user = sub.user or null;
    password = sub.password or null;
    token = sub.token or null;
  };

  subscriptionToYaml = sub: let
    base = {
      inherit (sub) topic command;
    };
    auth =
      optionalAttrs (sub.user != null) {user = sub.user;}
      // optionalAttrs (sub.password != null) {password = sub.password;}
      // optionalAttrs (sub.token != null) {token = sub.token;};
  in
    base // auth;

  configFile = pkgs.writeText "ntfy-client.yml" (builtins.toJSON {
    default-host = cfg.defaultHost;
    default-user = cfg.defaultUser;
    default-password = cfg.defaultPassword;
    default-token = cfg.defaultToken;
    subscribe = map subscriptionToYaml (map mkSubscription cfg.subscriptions);
  });
in {
  options.services.ntfy-client = {
    enable = mkEnableOption "ntfy client service for desktop notifications";

    package = mkOption {
      type = types.package;
      default = pkgs.ntfy-sh;
      description = "The ntfy package to use";
    };

    defaultHost = mkOption {
      type = types.str;
      default = "https://ntfy.sh";
      description = "Default ntfy server URL";
    };

    defaultUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default username for authentication";
    };

    defaultPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default password for authentication (consider using password-command instead)";
    };

    defaultToken = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default token for authentication";
    };

    subscriptions = mkOption {
      type = types.listOf (types.submodule {
        options = {
          topic = mkOption {
            type = types.str;
            description = "Topic name to subscribe to";
          };

          command = mkOption {
            type = types.str;
            default = ''notify-send "''${NTFY_TITLE:-ntfy}" "''${NTFY_MESSAGE}"'';
            description = "Command to execute when a message is received";
          };

          user = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Username for this subscription";
          };

          password = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Password for this subscription";
          };

          token = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Token for this subscription";
          };
        };
      });
      default = [];
      description = "List of topic subscriptions";
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    # Install ntfy package
    home.packages = [cfg.package pkgs.libnotify];

    # Create config directory and file
    xdg.configFile."ntfy/client.yml".source = configFile;

    # Set up systemd user service
    systemd.user.services.ntfy-client = {
      Unit = {
        Description = "ntfy client - desktop notification subscriber";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/ntfy subscribe --from-config";
        Restart = "on-failure";
        RestartSec = 10;

        # Environment variables for notification display
        Environment = [
          "DISPLAY=:0"
          "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
        ];
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}

{config, ...}: let
  pnpmGlobal = "${config.xdg.dataHome}/pnpm/global";
in {
  home.file = {
    ".config/op/plugins-nix.sh" = {
      source = ./op.sh;
    };
  };

  xdg = {
    configFile = {
      "pnpm/rc" = {
        text = ''
          global-dir=${pnpmGlobal}/packages
          prefix=${pnpmGlobal}
        '';
      };
    };
    dataFile = {
      "pnpm/global/bin/.keep" = {
        text = "";
      };
      "pnpm/global/packages/.keep" = {
        text = "";
      };
    };
  };
}

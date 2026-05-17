{
  pkgs,
  config,
  ...
}: let
  pnpmGlobal = "${config.xdg.dataHome}/pnpm/global";
in {
  home.packages = with pkgs; [
    pnpm
    biome
    nodejs_24
  ];

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

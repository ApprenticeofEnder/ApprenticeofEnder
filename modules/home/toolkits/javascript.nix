{
  pkgs,
  lib,
  config,
  ...
}: let
  home-lib = import ../lib {inherit lib;};
  inherit (home-lib) vscode;
  inherit (vscode) mkVsCode;
  inherit (vscode) setDefaultFormatters;

  pnpmGlobal = "${config.xdg.dataHome}/pnpm/global";
  vscodeConfig = mkVsCode {
    settings = lib.mergeAttrs [
      (
        setDefaultFormatters "esbenp.prettier-vscode" [
          "svelte"
          "vue"
        ]
      )
      (
        setDefaultFormatters "biomejs.biome" [
          # keep-sorted start
          "html"
          "javascript"
          "json"
          "typescript"
          "typescriptreact"
          # keep-sorted end
        ]
      )
    ];
    extensions = with pkgs.vscode-extensions; [
      biomejs.biome
      dbaeumer.vscode-eslint
      svelte.svelte-vscode
      vue.volar
    ];
  };
in
  lib.mkMerge [
    vscodeConfig
    {
      home.packages = with pkgs; [
        pnpm
        biome
        nodejs_24
        bun
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
  ]

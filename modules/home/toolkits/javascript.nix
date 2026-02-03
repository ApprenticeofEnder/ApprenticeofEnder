{
  pkgs,
  config,
  ...
}: let
  biomeDefault = {
    "editor.defaultFormatter" = "biomejs.biome";
  };
  prettierDefault = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };

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

  programs.vscode = {
    profiles = {
      default = {
        userSettings = {
          "[javascript]" = biomeDefault;
          "[html]" = biomeDefault;
          "[json]" = biomeDefault;
          "[typescript]" = biomeDefault;
          "[typescriptreact]" = biomeDefault;
          "[vue]" = prettierDefault;
          "[svelte]" = prettierDefault;
        };
        extensions = with pkgs.vscode-extensions; [
          vue.volar
          svelte.svelte-vscode
          unifiedjs.vscode-mdx

          # formatters and linters
          biomejs.biome
          dbaeumer.vscode-eslint
        ];
      };
    };
  };
}

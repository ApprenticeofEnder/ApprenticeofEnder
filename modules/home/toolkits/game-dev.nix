{
  pkgs,
  lib,
  ...
}: let
  home-lib = import ../lib {inherit lib;};
  inherit (home-lib) vscode;
  inherit (vscode) mkVsCode;

  vscodeConfig = mkVsCode {
    extensions = with pkgs.vscode-extensions; [
      geequlim.godot-tools
    ];
    variants = ["vscodium"];
  };
in
  lib.mkMerge [
    vscodeConfig
    {
      home = {
        packages = with pkgs; [
          godot # game engine
          gdtoolkit_4
        ];
      };
      programs = {
        nixvim = {
          lsp.servers.gdscript.enable = true;
          plugins = {
            godot.enable = true;
            conform-nvim.settings = {
              formatters_by_ft = {
                gdscript = [
                  "gdtoolkit_format"
                ];
              };

              linters_by_ft = {
                gdscript = [
                  "gdtoolkit_lint"
                ];
              };

              formatters = {
                gdtoolkit_format = {
                  command = "${pkgs.gdtoolkit_4}/bin/gdformat";
                  args = ["$FILENAME"];
                  stdin = false;
                };
              };

              linters = {
                gdtoolkit_lint = {
                  command = "${pkgs.gdtoolkit_4}/bin/gdlint";
                  args = ["$FILENAME"];
                  stdin = false;
                };
              };
            };
          };
        };
      };
    }
  ]

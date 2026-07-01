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
      rust-lang.rust-analyzer
    ];
  };
in
  lib.mkMerge [
    vscodeConfig
    {
      home.packages = with pkgs; [
        # keep-sorted start
        cargo
        cargo-binstall
        cargo-seek
        rust-analyzer
        rustfmt
        # keep-sorted end
      ];

      programs = {
        nixvim = {
          lsp.servers.rust_analyzer.enable = true;
        };
      };
    }
  ]

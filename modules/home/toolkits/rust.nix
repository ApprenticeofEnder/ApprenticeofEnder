{pkgs, ...}: {
  home.packages = with pkgs; [
    # keep-sorted start
    cargo
    cargo-binstall
    cargo-seek
    rust-analyzer
    rustfmt
    # keep-sorted end
  ];

  programs = let
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
    ];
  in {
    vscode = {
      profiles = {
        default = {
          inherit extensions;
        };
      };
    };
    vscodium = {
      profiles = {
        default = {
          inherit extensions;
        };
      };
    };
    nixvim = {
      lsp.servers.rust_analyzer.enable = true;
    };
  };
}

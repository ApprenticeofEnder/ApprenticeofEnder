{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    rustfmt
    cargo-seek
    rust-analyzer
  ];

  programs.vscode = {
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          rust-lang.rust-analyzer
        ];
      };
    };
  };
}

{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    rustfmt
    cargo-seek
    rust-analyzer
  ];

  progams.vscode = {
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          rust-lang.rust-analyzer
        ];
      };
    };
  };
}

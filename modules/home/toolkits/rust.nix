{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    rustfmt
    cargo-seek
    rust-analyzer
  ];
}

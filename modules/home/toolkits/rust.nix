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
}

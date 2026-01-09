{pkgs, ...}: {
  home.packages = with pkgs; [
    shfmt
    stylua
    prettier
    alejandra
  ];
}

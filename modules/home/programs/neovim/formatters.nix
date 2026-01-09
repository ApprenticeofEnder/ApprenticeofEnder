{pkgs, ...}: {
  home.packages = with pkgs; [
    jqfmt
    shfmt
    stylua
    prettier
    alejandra
  ];
}

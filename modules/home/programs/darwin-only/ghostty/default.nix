{nurpkgs, ...}: {
  home.packages = with nurpkgs.repos.gigamonster256; [
    ghostty-darwin
  ];
}

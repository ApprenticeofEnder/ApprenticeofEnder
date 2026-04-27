{
  pkgs,
  pkgs-stable,
  ...
}: {
  programs.lutris = {
    enable = true;
    package = pkgs-stable.lutris;
    winePackages = with pkgs; [wineWow64Packages.full];
  };
}

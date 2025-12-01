{ pkgs, ... }:
{
  home.shellAliases = {
    cat = "bat";
  };
  programs.bat = {
    enable = true;
  };
}

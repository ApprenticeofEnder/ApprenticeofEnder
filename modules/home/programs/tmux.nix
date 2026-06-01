{
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shell = "${lib.getExe pkgs.fish}";
  };
}

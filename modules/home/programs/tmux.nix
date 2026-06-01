{
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shell = "${lib.getExe pkgs.fish}";
    extraConfig = ''
      set -g allow-passthrough on
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'
    '';
  };
}

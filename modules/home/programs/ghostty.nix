{
  pkgs,
  lib,
  ...
}: let
  workingDirectory =
    if pkgs.stdenv.isDarwin
    then "home"
    else "inherit";
in
  lib.mkMerge [
    {
      programs.ghostty = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        settings = {
          command = "${pkgs.fish}/bin/fish";
          scrollback-limit = 30000000;
          window-decoration = "client";
          window-height = 3000;
          window-width = 3000;

          theme = "Nord";
          # font-size = 11;
          font-family = "Hack Nerd Font";
          keybind = [
            # Split
            "super+d=new_split:right"
            "super+shift+d=new_split:down"
            # Across
            "super+t=new_tab"
            "super+shift+left=previous_tab"
            "super+shift+right=next_tab"
            # Navigate
            "super+alt+h=goto_split:left"
            "super+alt+l=goto_split:right"
            "super+alt+k=goto_split:up"
            "super+alt+j=goto_split:down"
            "super+shift+e=equalize_splits"
            "super+shift+f=toggle_split_zoom"
            # Destroy
            "super+w=close_surface"
            # Clipboard
            "ctrl+shift+v=paste_from_selection"
            "ctrl+v=paste_from_clipboard"
            # Font Size
            "super+plus=increase_font_size:1"
            "super+minus=decrease_font_size:1"
            "super+0=reset_font_size"
          ];

          copy-on-select = "clipboard";
          env = [
            "LS_COLORS=1"
          ];

          macos-option-as-alt = true;

          working-directory = workingDirectory;
        };
      };
    }
    (lib.mkIf pkgs.stdenv.isDarwin {
      programs.ghostty.package = pkgs.ghostty-bin;
    })
  ]

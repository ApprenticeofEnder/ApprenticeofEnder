{...}: {
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      scrollback-limit = 10000;
      window-decoration = "client";
      window-height = 3000;
      window-width = 3000;

      theme = "Nord";
      font-size = 11;
      font-family = "Hack Nerd Font";
      keybind = [
        "ctrl+w>v=new_split:right"
        "ctrl+w>s=new_split:down"
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+l=goto_split:right"
        "ctrl+shift+k=goto_split:up"
        "ctrl+shift+j=goto_split:down"
        "ctrl+shift+v=paste_from_selection"
      ];

      copy-on-select = "clipboard";
      env = [
        "LS_COLORS=1"
      ];

      macos-option-as-alt = true;

      working-directory = "inherit";
    };
  };
}

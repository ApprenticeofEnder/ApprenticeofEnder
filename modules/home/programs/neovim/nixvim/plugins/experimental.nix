{
  /*
  Plugins to look at:
  # keep-sorted start
  https://github.com/alexpasmantier/tv.nvim/
  https://github.com/wintermute-cell/gitignore.nvim/
  https://nix-community.github.io/nixvim/plugins/friendly-snippets/index.html
  https://nix-community.github.io/nixvim/plugins/overseer/index.html

  # keep-sorted end
  */
  plugins = {
    # keep-sorted start block=yes
    codesettings = {
      enable = true;
      settings = {
        config_file_paths = [
          ".vscode/settings.json"
          "codesettings.json"
          "lspsettings.json"
          ".codesettings.json"
          ".lspsettings.json"
          ".nvim/codesettings.json"
          ".nvim/lspsettings.json"
        ];
        default_merge_opts = {
          list_behavior = "prepend";
        };
        jsonls_integration = true;
      };
    };
    debugprint.enable = true;
    flutter-tools.enable = true;
    gitignore.enable = true;
    glow.enable = true;
    harpoon.enable = true;
    opencode.enable = true;
    wrapping.enable = true;
    # keep-sorted end
  };
}

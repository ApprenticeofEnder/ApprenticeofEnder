{lib, ...}: {
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
      enable = lib.mkIf lib.nixvim.enableExceptInTests true;
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
    debugprint.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    easy-dotnet.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    flutter-tools.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    gitignore.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    glow.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    harpoon.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    octo.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    opencode.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    wrapping.enable = lib.mkIf lib.nixvim.enableExceptInTests true;
    # keep-sorted end
  };
}

{...}: {
  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    imports = [
      ./plugins
      ./autocmds.nix
      ./lsp.nix
      ./options.nix
    ];

    # colorschemes = {
    #   nord.enable = true;
    # };

    keymaps = [
      /*
      all keymaps from mappings.lua
      */
    ];
    # extraConfigLua = ''/* hover.lua inline */ '';
  };
}

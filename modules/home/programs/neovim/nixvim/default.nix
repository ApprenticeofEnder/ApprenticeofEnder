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

    colorscheme = "onenord";
    extraConfigLuaPre = ''require('onenord').setup() '';

    keymaps = [
      /*
      all keymaps from mappings.lua
      */
    ];
    extraConfigLua = ''/* hover.lua inline */ '';
  };
}

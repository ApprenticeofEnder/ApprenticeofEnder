{...}: {
  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    imports = [
      ./plugins
    ];

    opts = {
      /*
      all options from options.lua
      */
    };
    colorscheme = "onenord";
    extraConfigLuaPre = ''require('onenord').setup() '';

    keymaps = [
      /*
      all keymaps from mappings.lua
      */
    ];
    autoGroups = {
      /*
      augroups from autocmds.lua
      */
    };
    autoCmd = [
      /*
      autocmds from autocmds.lua
      */
    ];
    extraConfigLua = ''/* hover.lua inline */ '';
  };
}

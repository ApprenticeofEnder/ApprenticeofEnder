{pkgs, ...}:
# this automatically imports everything else in the parent folder
let
  filterFiles = filename: (
    filename
    != "default.nix"
  );
in {
  imports = with builtins;
    map (fn: ./${fn}) (filter filterFiles (attrNames (readDir ./.)));
  plugins = {
    lsp = {
      /*
      translated from lspconfig.lua
      */
    };
    /*
    + telescope, lualine, etc. to replace NvChad UI bits
    */
  };

  extraPlugins = with pkgs.vimPlugins; [
    onenord-nvim
    treewalker-nvim
    nvim-hlslens
  ];
}

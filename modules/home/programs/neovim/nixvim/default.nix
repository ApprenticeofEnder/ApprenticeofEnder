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
      ./mappings.nix
    ];

    colorschemes = {
      nord.enable = true;
    };

    # extraConfigLua = ''/* hover.lua inline */ '';
  };
}

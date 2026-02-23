{
  pkgs,
  lib,
  nixosConfig,
  ...
}: let
  isNixOS = nixosConfig != null;
in {
  home.sessionVariables = {
    NIX_NEOVIM =
      if isNixOS
      then "1"
      else "0";
  };
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withRuby = true;
      withNodeJs = true;
      withPython3 = true;
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [
        LazyVim
      ];

      extraPackages = with pkgs;
        lib.mkIf isNixOS [
          nil
          taplo
          biome
          hclfmt
          jq-lsp
          tflint
          rustfmt
          fish-lsp
          marksman
          prettier
          tinymist
          ansible-lint
          basedpyright
          terraform-ls
          rust-analyzer
          lua-language-server
          vue-language-server
          bash-language-server
          yaml-language-server
          docker-language-server
          svelte-language-server
          vscode-css-languageserver
          typescript-language-server
          vscode-json-languageserver
          tailwindcss-language-server
        ];
    };
  };

  # home = {
  #   file = {
  #     ".config/nvim/init.lua" = {
  #       enable = false;
  #       text = ''
  #         -- bootstrap lazy.nvim, LazyVim and your plugins
  #         require("config.lazy")
  #       '';
  #     };
  #     ".config/nvim/lua/plugins" = {
  #       enable = false;
  #       source = ./plugins;
  #       recursive = true;
  #     };
  #     ".config/nvim/lua/config" = {
  #       enable = false;
  #       source = ./config;
  #       recursive = true;
  #     };
  #     ".config/nvim/lazyvim.json" = {
  #       enable = false;
  #       source = ./lazyvim.json;
  #     };
  #     ".config/nvim/.neoconf.json" = {
  #       enable = false;
  #       text = ''
  #         {
  #           "neodev": {
  #             "library": {
  #               "enabled": true,
  #               "plugins": true
  #             }
  #           },
  #           "neoconf": {
  #             "plugins": {
  #               "lua_ls": {
  #                 "enabled": true
  #               }
  #             }
  #           }
  #         }
  #       '';
  #     };
  #     ".config/nvim/stylua.toml" = {
  #       enable = false;
  #       text = ''
  #         indent_width = 2
  #         column_width = 120
  #         indent_type = "Spaces"
  #       '';
  #     };
  #   };
  # };
}

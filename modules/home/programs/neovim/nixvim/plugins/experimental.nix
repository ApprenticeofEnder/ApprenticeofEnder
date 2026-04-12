{
  /*
  Plugins to look at:
  https://nix-community.github.io/nixvim/plugins/fastaction/index.html
  https://github.com/folke/flash.nvim/
  https://nix-community.github.io/nixvim/plugins/flutter-tools/index.html
  https://nix-community.github.io/nixvim/plugins/friendly-snippets/index.html
  https://github.com/wintermute-cell/gitignore.nvim/
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
    diagram = {
      enable = true;
      settings = {
        integrations = [
          {
            __raw = "require('diagram.integrations.markdown')";
          }
          {
            __raw = "require('diagram.integrations.neorg')";
          }
        ];
        renderer_options = {
          d2 = {
            theme_id = 1;
          };
          gnuplot = {
            size = "800,600";
            theme = "dark";
          };
          mermaid = {
            theme = "forest";
          };
          plantuml = {
            charset = "utf-8";
          };
        };
      };
    };
    eyeliner.enable = true;
    harpoon.enable = true;
    indent-blankline.enable = true;
    indent-blankline.settings = {
      exclude = {
        buftypes = [
          "terminal"
          "quickfix"
        ];
        filetypes = [
          ""
          "checkhealth"
          "help"
          "lspinfo"
          "packer"
          "TelescopePrompt"
          "TelescopeResults"
          "yaml"
        ];
      };
      indent = {
        char = "│";
      };
      scope = {
        show_end = false;
        show_exact_scope = true;
        show_start = false;
      };
    };
    precognition.enable = true;
    snacks.enable = true;
    # keep-sorted end
  };
}

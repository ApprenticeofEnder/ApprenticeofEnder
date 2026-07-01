{
  pkgs,
  lib,
  ...
}: {
  plugins = {
    conform-nvim = {
      enable = true;
      autoInstall.enable = true;
      settings = {
        formatters_by_ft = let
          assignFormatters = formatters: languages:
            builtins.listToAttrs (
              map (
                language: {
                  name = language;
                  value = formatters;
                }
              )
              languages
            );
        in
          {
            # keep-sorted start block=yes
            # TODO: Work out what's going on here
            # c = [
            #   "clangd-format"
            # ];
            hcl = [
              "hclfmt"
            ];
            lua = [
              "stylua"
            ];
            nix = [
              "alejandra"
            ];
            python = [
              "ruff_fix"
              "ruff_format"
              "ruff_organize_imports"
            ];
            rust = [
              "rustfmt"
            ];
            typst = [
              "typstyle"
            ];
            # keep-sorted end
          }
          // assignFormatters ["js_formatting"] [
            # keep-sorted start
            "css"
            "html"
            "javascript"
            "javascriptreact"
            "json"
            "jsonc"
            "tsx"
            "typescript"
            "typescriptreact"
            # keep-sorted end
          ]
          // assignFormatters ["prettier"] [
            # keep-sorted start
            "markdown"
            "svelte"
            "vue"
            "yaml"
            # keep-sorted end
          ];
        linters_by_ft = {
          # keep-sorted start block=yes
          bash = ["shellcheck"];
          make = ["checkmake"];
          terraform = ["tflint"];
          zsh = ["shellcheck"];
          # keep-sorted end
        };
        formatters = {
          hclfmt = {
            command = lib.getExe pkgs.hclfmt;
          };
          shellcheck = {
            command = lib.getExe pkgs.shellcheck;
          };

          js_formatting = lib.nixvim.mkRaw ''
            function(bufnr)
              local prettier_config = require("conform.formatters.prettier")
              local biome_config = require("conform.formatters.biome")
              local config = prettier_config
              config.command = "${lib.getExe pkgs.prettier}"
              if require("conform").get_formatter_info("biome", bufnr).available then
                config = biome_config
                config.command = "${lib.getExe pkgs.biome}"
              end
              return config
            end
          '';
        };
        format_on_save = {
          # These options will be passed to conform.format()
          timeout_ms = 10000;
          lsp_fallback = true;
        };
      };
    };
  };
}

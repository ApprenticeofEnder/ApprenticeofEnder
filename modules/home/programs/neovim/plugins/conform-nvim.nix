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
          assignBiomeOrPrettier = languages:
            builtins.listToAttrs (
              map (
                language: {
                  name = language;
                  value = {
                    __unkeyed-1 = "biome";
                    __unkeyed-2 = "prettier";
                    stop_after_first = true;
                  };
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
          // assignBiomeOrPrettier [
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
          biome = {
            command = lib.getExe pkgs.biome;
            require_cwd = true;
          };
          hclfmt = {
            command = lib.getExe pkgs.hclfmt;
          };
          prettier = {
            command = lib.getExe pkgs.prettier;
            require_cwd = true;
          };
          shellcheck = {
            command = lib.getExe pkgs.shellcheck;
          };
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

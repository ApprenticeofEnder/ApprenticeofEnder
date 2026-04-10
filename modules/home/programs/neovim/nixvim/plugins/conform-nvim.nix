{
  pkgs,
  lib,
  ...
}: {
  plugins = {
    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = let
          jsFormatting = {
            __unkeyed-1 = "biome";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };

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
            c = [
              "clangd-format"
            ];
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
            ];
            rust = [
              "rustfmt"
            ];
            typst = [
              "typstyle"
            ];
            # keep-sorted end
          }
          // assignFormatters jsFormatting [
            # keep-sorted start
            "css"
            "html"
            "javascript"
            "javascriptreact"
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

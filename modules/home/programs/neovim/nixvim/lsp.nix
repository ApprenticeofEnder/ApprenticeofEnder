{
  lib,
  pkgs,
  ...
}: let
  enabledServers = [
    # keep-sorted start
    "ansiblels"
    "basedpyright"
    "bashls"
    "biome"
    "cssls"
    "docker_compose_language_service"
    "dockerls"
    "eslint"
    "fish_lsp"
    "gopls"
    "html"
    "jqls"
    "jsonls"
    "marksman"
    "nil_ls"
    "ruff"
    "rust_analyzer"
    "svelte"
    "systemd_lsp"
    "tailwindcss"
    "taplo"
    "terraformls"
    "tflint"
    "tinymist"
    "ts_ls"
    "yamlls"
    # keep-sorted end
  ];
in {
  plugins.lspconfig.enable = true;
  lsp = {
    servers =
      {
        # keep-sorted start block=yes
        "*" = {
          config = {
            capabilities = {
              textDocument = {
                semanticTokens = {
                  multilineTokenSupport = true;
                };
              };
            };
            root_markers = [
              ".git"
            ];
          };
        };
        basedpyright = {
          config = {
            settings = {
              pyright = {
                disableOrganizeImports = true;
              };
              python = {
                analysis = {
                  ignore = [
                    "*"
                  ];
                };
              };
            };
          };
        };
        bashls = {
          config.filetypes = [
            "bash"
            "sh"
            "zsh"
          ];
        };
        biome = {
          config.filetypes = [
            "javascript"
            "javascriptreact"
            "typescript"
            "typescriptreact"
            "json"
            "jsonc"
            "css"
            "html"
          ];
        };
        cssls = {
          config.settings = {
            css.lint = {
              unknownAtRules = "ignore";
            };
          };
        };
        eslint = {
          config.settings = {
            # Keep formatting with conform/prettier/biome and let ESLint focus on
            # diagnostics and fix/code-action workflows.
            format = false;
            # Upstream can resolve a workspace-local ESLint install on its own,
            # but Nix-managed projects need an explicit global fallback.
            nodePath = "${pkgs.eslint}/lib/node_modules";
          };
        };
        nil_ls = {
          enable = true;
        };
        tailwindcss = {
          config.filetypes = [
            "css"
            "scss"
            "sass"
            "html"
            "javascriptreact"
            "typescriptreact"
            "vue"
            "svelte"
          ];
        };
        yamlls = {
          config = {
            settings = {
              yaml.schemas = lib.nixvim.mkRaw ''
                {
                  kubernetes = "k8s-*.yaml",
                  ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
                  ["http://json.schemastore.org/github-action"] = ".github/**/actions?.{yml,yaml}",
                  ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
                  ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
                  ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
                  ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
                  ["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
                }
              '';
            };
          };
        };
        # keep-sorted end
      }
      // builtins.listToAttrs (
        map (server: {
          name = server;
          value = {
            enable = true;
          };
        })
        enabledServers
      );
  };
}

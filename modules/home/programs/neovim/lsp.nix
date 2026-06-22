{
  lib,
  pkgs,
  ...
}: let
  # vscode-langservers-extracted ships a babel bundle whose jsonServerMain.js mixes
  # CommonJS require() with import.meta.url, so Node treats it as ESM and crashes.
  # Use VSCodium's native bundled server instead (see nix-community/nixvim#4431).
  vscodiumExtensions =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "${pkgs.vscodium}/Applications/VSCodium.app/Contents/Resources/app/extensions"
    else "${pkgs.vscodium}/resources/app/extensions";

  mkVsCodeLspPackage = language: let
    languageServerMainSrc = "${vscodiumExtensions}/${language}-language-features/server/dist/node/${language}ServerMain.js";
    languageServerMain = "$out/lib/${language}ServerMain.js";
    binary = "$out/bin/vscode-${language}-language-server";
  in
    pkgs.runCommand "vscode-${language}-language-server" {
      nativeBuildInputs = [pkgs.makeWrapper pkgs.nodejs];
      meta.mainProgram = "vscode-${language}-language-server";
    } ''
      mkdir -p $out/lib $out/bin
      cp ${languageServerMainSrc} ${languageServerMain}
      makeWrapper ${lib.getExe pkgs.nodejs} ${binary} \
        --add-flags ${languageServerMain} \
        --append-flags "--stdio"
    '';

  mkVsCodeLspCmd = package: [
    (lib.getExe package)
    "--stdio"
  ];

  jsonLanguageServerPackage = mkVsCodeLspPackage "json";
  cssLanguageServerPackage = mkVsCodeLspPackage "css";
  htmlLanguageServerPackage = mkVsCodeLspPackage "html";

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
    "graphql"
    "html"
    "jqls"
    "jsonls"
    "lua_ls"
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
    servers = lib.mkMerge [
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
              basedpyright = {
                disableOrganizeImports = true;
                analysis = {
                  ignore = ["*"];
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
          package = cssLanguageServerPackage;
          config = {
            cmd = mkVsCodeLspCmd cssLanguageServerPackage;
            settings = {
              css.lint = {
                unknownAtRules = "ignore";
              };
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
        html = {
          package = htmlLanguageServerPackage;
          config.cmd = mkVsCodeLspCmd htmlLanguageServerPackage;
        };
        jsonls = {
          package = jsonLanguageServerPackage;
          config.cmd = mkVsCodeLspCmd jsonLanguageServerPackage;
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
        terraformls = {
          config = {
            root_markers = [
              ".terraform"
              ".terraform.lock.hcl"
              ".git"
            ];
          };
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
      (builtins.listToAttrs (
        map (server: {
          name = server;
          value = {
            enable = true;
          };
        })
        enabledServers
      ))
    ];
  };
}

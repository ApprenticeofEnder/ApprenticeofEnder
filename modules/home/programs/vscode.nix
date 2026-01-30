{
  pkgs,
  lib,
  ...
}: let
  biome = "biomejs.biome";
  prettier = "esbenp.prettier-vscode";

  biomeDefault = {
    "editor.defaultFormatter" = biome;
  };
  prettierDefault = {
    "editor.defaultFormatter" = prettier;
  };

  userSettings = {
    "extensions.experimental.affinity" = {
      "asvetliakov.vscode-neovim" = 1;
    };

    "[javascript]" = biomeDefault;
    "[html]" = biomeDefault;
    "[json]" = biomeDefault;
    "[typescript]" = biomeDefault;
    "[typescriptreact]" = biomeDefault;
    "[vue]" = prettierDefault;
    "[svelte]" = prettierDefault;

    "editor.formatOnSave" = true;
    "editor.wordWrap" = "on";

    "workbench.colorTheme" = "Nord";
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.sideBar.location" = "right";
  };
in
  lib.mkMerge [
    # Shared
    {
      programs.vscode = {
        enable = true;
        profiles = {
          default = {
            userSettings = userSettings;
            extensions = with pkgs.vscode-extensions; [
              # languages
              bbenoist.nix
              hashicorp.hcl
              redhat.ansible
              ms-python.python
              redhat.vscode-yaml
              hashicorp.terraform

              # formatters and linters
              mkhl.shfmt
              charliermarsh.ruff
              esbenp.prettier-vscode
              detachhead.basedpyright

              # theme
              pkief.material-icon-theme
              pkief.material-product-icons
              arcticicestudio.nord-visual-studio-code

              # utilities
              docker.docker
              tomoki1207.pdf
              eamodio.gitlens
              usernamehw.errorlens
              asvetliakov.vscode-neovim
              github.vscode-github-actions
            ];
          };
        };
      };
    }
    # MacOS
    (
      lib.mkIf pkgs.stdenv.isDarwin {
        programs.vscode = {
          package = pkgs.vscode;
          profiles = {
            default = {
              extensions = with pkgs.vscode-extensions; [
                # languages
                ms-dotnettools.csharp
                ms-dotnettools.csdevkit
                ms-dotnettools.vscode-dotnet-runtime

                # formatters and linters
                csharpier.csharpier-vscode
              ];
            };
          };
        };
      }
    )
    # Linux
    (
      lib.mkIf pkgs.stdenv.isLinux {
        home.packages = [
          pkgs.biome
        ];
        programs.vscode = {
          package = pkgs.vscodium;
          profiles = {
            default = {
              userSettings = userSettings;
              extensions = with pkgs.vscode-extensions; [
                # languages
                vue.volar
                svelte.svelte-vscode
                unifiedjs.vscode-mdx
                geequlim.godot-tools
                rust-lang.rust-analyzer

                # formatters and linters
                dbaeumer.vscode-eslint
                formulahendry.auto-close-tag
              ];
            };
          };
        };
      }
    )
  ]

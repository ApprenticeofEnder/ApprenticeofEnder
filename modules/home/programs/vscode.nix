{
  pkgs,
  lib,
  ...
}: let
  biomeDefault = {
    "editor.defaultFormatter" = "biomejs.biome";
  };
  prettierDefault = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };

  userSettings = {
    "extensions.experimental.affinity" = {
      "asvetliakov.vscode-neovim" = 1;
    };

    "editor.formatOnSave" = true;
    "editor.wordWrap" = "on";
    "editor.lineNumbers" = "relative";

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
            extensions = with pkgs.vscode-extensions; let
              languages = [
                # keep-sorted start
                bbenoist.nix
                hashicorp.hcl
                hashicorp.terraform
                ms-python.python
                redhat.ansible
                redhat.vscode-yaml
                # keep-sorted end
              ];
              formattersAndLinters = [
                # keep-sorted start
                charliermarsh.ruff
                detachhead.basedpyright
                esbenp.prettier-vscode
                mkhl.shfmt
                # keep-sorted end
              ];
              theme = [
                # keep-sorted start
                arcticicestudio.nord-visual-studio-code
                pkief.material-icon-theme
                pkief.material-product-icons
                # keep-sorted end
              ];
              utilities = [
                # keep-sorted start
                asvetliakov.vscode-neovim
                docker.docker
                eamodio.gitlens
                github.vscode-github-actions
                joshmu.periscope
                tomoki1207.pdf
                usernamehw.errorlens
                # keep-sorted end
              ];
            in
              languages
              ++ formattersAndLinters
              ++ theme
              ++ utilities;
          };
        };
      };
    }
    # MacOS
    (
      lib.mkIf pkgs.stdenv.isDarwin {
        programs.vscode = {
          # Disable this shit until I can figure out why my C# intellisense doesn't work
          enable = lib.mkForce false;
          package = pkgs.vscode;
          profiles = {
            default = {
              userSettings = {
                "[csharp]" = {
                  "editor.defaultFormatter" = "csharpier.csharpier-vscode";
                  "editor.formatOnSave" = false;
                };
              };
              extensions = with pkgs.vscode-extensions; [
                # formatters and linters
                csharpier.csharpier-vscode

                # Utilities
                alefragnani.project-manager
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
              userSettings = {
                "[javascript]" = biomeDefault;
                "[html]" = biomeDefault;
                "[json]" = biomeDefault;
                "[typescript]" = biomeDefault;
                "[typescriptreact]" = biomeDefault;
                "[vue]" = prettierDefault;
                "[svelte]" = prettierDefault;
                "[cobol]" = {
                  "editor.defaultFormatter" = "OCamlPro.SuperBOL";
                };
              };
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

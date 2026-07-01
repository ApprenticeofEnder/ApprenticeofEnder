{
  pkgs,
  lib,
  ...
}: let
  home-lib = import ../lib {inherit lib;};
  inherit (home-lib) vscode;
  inherit (vscode) mkVsCode;

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

  sharedConfigs = mkVsCode {
    variants = ["vscode" "vscodium"];
    settings = userSettings;
    extensions = with pkgs.vscode-extensions; let
      languages = [
        # keep-sorted start
        # bbenoist.nix
        hashicorp.hcl
        hashicorp.terraform
        jnoortheen.nix-ide
        redhat.ansible
        redhat.vscode-yaml
        tamasfe.even-better-toml
        # keep-sorted end
      ];
      formattersAndLinters = [
        # keep-sorted start
        davidanson.vscode-markdownlint
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
        aaron-bond.better-comments
        alefragnani.project-manager
        asvetliakov.vscode-neovim
        christian-kohler.path-intellisense
        docker.docker
        eamodio.gitlens
        github.vscode-github-actions
        gruntfuggly.todo-tree
        joshmu.periscope
        tomoki1207.pdf
        usernamehw.errorlens
        vspacecode.whichkey
        # keep-sorted end
      ];
    in
      languages
      ++ formattersAndLinters
      ++ theme
      ++ utilities;
  };

  linuxConfig = mkVsCode {
    variants = ["vscodium"];
    extensions = with pkgs.vscode-extensions; let
      languages = [
        # keep-sorted start
        graphql.vscode-graphql
        graphql.vscode-graphql-syntax
        unifiedjs.vscode-mdx
        # keep-sorted end
      ];
      formattersAndLinters = [
        # keep-sorted start
        formulahendry.auto-close-tag
        formulahendry.auto-rename-tag
        # keep-sorted end
      ];
    in
      languages
      ++ formattersAndLinters;
  };
  darwinConfig = mkVsCode {
    variants = ["vscode"];
    settings = {
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
in
  lib.mkMerge [
    sharedConfigs
    # MacOS
    (
      lib.mkIf pkgs.stdenv.isDarwin (
        darwinConfig
        // {
          programs.vscode.enable = false; # Disabled due to issues with LSP
        }
      )
    )
    # Linux
    (
      lib.mkIf pkgs.stdenv.isLinux (
        linuxConfig
        // {
          home.packages = [
            pkgs.biome
          ];
          programs.vscodium.enable = true;
        }
      )
    )
  ]

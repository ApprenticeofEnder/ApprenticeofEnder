{
  pkgs,
  lib,
  ...
}: let
  setDefaultFormatters = formatter: languages: (
    builtins.listToAttrs (
      map (language: {
        name = "[${language}]";
        value = {
          "editor.defaultFormatter" = formatter;
        };
      })
      languages
    )
  );

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

  mkVsCode = variant: {
    settings,
    extensions,
  }: {
    programs."${variant}" = {
      profiles = {
        default = {
          userSettings = settings;
          extensions = extensions;
        };
      };
    };
  };

  sharedConfigs = map (
    variant:
      mkVsCode variant {
        settings = userSettings;
        extensions = with pkgs.vscode-extensions; let
          languages = [
            # keep-sorted start
            bbenoist.nix
            hashicorp.hcl
            hashicorp.terraform
            ms-python.python
            redhat.ansible
            redhat.vscode-yaml
            tamasfe.even-better-toml
            # keep-sorted end
          ];
          formattersAndLinters = [
            # keep-sorted start
            charliermarsh.ruff
            davidanson.vscode-markdownlint
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
      }
  ) ["vscodium" "vscode"];

  linuxConfig = mkVsCode "vscodium" {
    settings =
      (
        setDefaultFormatters "esbenp.prettier-vscode" [
          "svelte"
          "vue"
        ]
      )
      // (
        setDefaultFormatters "biomejs.biome" [
          # keep-sorted start
          "html"
          "javascript"
          "json"
          "typescript"
          "typescriptreact"
          # keep-sorted end
        ]
      )
      // setDefaultFormatters "OCamlPro.SuperBOL" ["cobol"];
    extensions = with pkgs.vscode-extensions; let
      languages = [
        # keep-sorted start
        geequlim.godot-tools
        graphql.vscode-graphql
        graphql.vscode-graphql-syntax
        rust-lang.rust-analyzer
        svelte.svelte-vscode
        unifiedjs.vscode-mdx
        vue.volar
        # keep-sorted end
      ];
      formattersAndLinters = [
        # keep-sorted start
        biomejs.biome
        dbaeumer.vscode-eslint
        formulahendry.auto-close-tag
        formulahendry.auto-rename-tag
        # keep-sorted end
      ];
    in
      languages
      ++ formattersAndLinters;
  };
  darwinConfig = mkVsCode "vscode" {
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
  lib.mkMerge (
    sharedConfigs
    ++ [
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
  )

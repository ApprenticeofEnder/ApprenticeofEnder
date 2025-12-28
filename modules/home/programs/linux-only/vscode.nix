{pkgs, ...}: let
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
in {
  home.packages = [
    pkgs.biome
  ];
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles = {
      default = {
        userSettings = userSettings;
        extensions = with pkgs.vscode-extensions; [
          # languages
          vue.volar
          bbenoist.nix
          hashicorp.hcl
          redhat.ansible
          ms-python.python
          hashicorp.terraform
          svelte.svelte-vscode
          unifiedjs.vscode-mdx
          rust-lang.rust-analyzer

          # formatters and linters
          mkhl.shfmt
          biomejs.biome
          charliermarsh.ruff
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
          detachhead.basedpyright
          formulahendry.auto-close-tag

          # theme
          pkief.material-icon-theme
          pkief.material-product-icons
          arcticicestudio.nord-visual-studio-code

          # utilities
          docker.docker
          eamodio.gitlens
          asvetliakov.vscode-neovim
          github.vscode-github-actions
        ];
      };
    };
  };
}

{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          # languages
          vue.volar
          bbenoist.nix
          hashicorp.hcl
          redhat.ansible
          ms-python.python
          hashicorp.terraform
          svelte.svelte-vscode
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
          asvetliakov.vscode-neovim
          github.vscode-github-actions
        ];
      };
    };
  };
}

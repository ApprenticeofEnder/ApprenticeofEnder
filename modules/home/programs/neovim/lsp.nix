{pkgs, ...}: {
  home.packages = with pkgs; [
    # general language servers
    gopls
    taplo
    jq-lsp
    marksman
    tinymist
    lua-language-server
    vue-language-server
    bash-language-server
    yaml-language-server
    svelte-language-server
    docker-language-server
    dockerfile-language-server
    typescript-language-server
    tailwindcss-language-server

    # terraform
    tflint
    terraform-ls

    # vscode extracted
    # vscode-css-languageserver
    # vscode-json-languageserver
    vscode-langservers-extracted

    # nix
    nil

    # python
    ruff
    basedpyright

    # rust
    rust-analyzer
  ];
}

{pkgs, ...}: let
  makeLanguageServer = language: pkgs."${language}-language-server";
  languageServers = with pkgs;
    [
      nil
      taplo
      jq-lsp
      fish-lsp
      marksman
      tinymist
      terraform-ls
      rust-analyzer
      vscode-css-languageserver
      vscode-json-languageserver
    ]
    ++ map makeLanguageServer [
      "lua"
      "vue"
      "bash"
      "yaml"
      "docker"
      "svelte"
      "typescript"
      "tailwindcss"
    ];

  formatters = with pkgs; [
    biome
    hclfmt
    rustfmt
    prettier
  ];

  linters = with pkgs; [
    tflint
    ansible-lint
    basedpyright
    terraform-ls
  ];

  tsGrammars = with pkgs.vimPlugins.nvim-treesitter-parsers; [
    css
    hcl
    lua
    html
    just
    json
    rust
    yaml
    toml
    python
    svelte
    terraform
    dockerfile
    javascript
    typescript
  ];
in {
  programs.neovim = {
    plugins = tsGrammars;
    extraPackages = languageServers ++ formatters ++ linters;
  };
}

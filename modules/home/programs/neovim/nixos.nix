{pkgs, ...}: let
  makeLanguageServer = language: "${language}-language-server";
  makeTsGrammar = language: "tree-sitter-${language}";
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
    ]
    ++ map makeLanguageServer [
      "lua"
      "vue"
      "bash"
      "yaml"
      "docker"
      "svelte"
      "vscode-css"
      "typescript"
      "vscode-json"
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

  tsGrammars = with pkgs.tree-sitter-grammars;
    map makeTsGrammar [
      css
      hcl
      lua
      html
      just
      rust
      yaml
      python
      svelte
      dockerfile
      javascript
      typescript
      rust-format-args
    ];
in {
  programs.neovim = {
    extraPackages = languageServers ++ formatters ++ linters ++ tsGrammars;
  };
}

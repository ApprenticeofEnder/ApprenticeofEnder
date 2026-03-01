{pkgs, ...}: let
  makeLanguageServer = language: pkgs."${language}-language-server";
  makeTsGrammar = language: pkgs.tree-sitter-grammars."tree-sitter-${language}";
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

  tsGrammars = map makeTsGrammar [
    "css"
    "hcl"
    "lua"
    "html"
    "just"
    "rust"
    "yaml"
    "python"
    "svelte"
    "dockerfile"
    "javascript"
    "typescript"
    "rust-format-args"
  ];
in {
  programs.neovim = {
    extraPackages = languageServers ++ formatters ++ linters ++ tsGrammars;
  };
}

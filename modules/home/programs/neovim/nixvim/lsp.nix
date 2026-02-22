{...}: let
  lspList = [
    "basedpyright"
    "bashls"
    "biome"
    "cssls"
    "docker_compose_language_service"
    "docker_language_server"
    "eslint"
    "fish_lsp"
    "jqls"
    "jsonls"
    "just"
    "lua_ls"
    "marksman"
    "nil_ls"
    "prettier"
    "ruff"
    "rust_analyzer"
    "svelte"
    "stylua"
    "terraform_lsp"
  ];
  enabledLsps = builtins.listToAttrs (
    map
    (lsp: {
      name = lsp;
      value = {
        enable = true;
      };
    })
    lspList
  );
in {
  lsp.servers = enabledLsps;
}

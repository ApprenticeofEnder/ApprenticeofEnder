{lib, ...}: let
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
  defaultActivatedLsps = [
    "bashls"
    "docker_language_server"
    "docker_compose_language_service"
    "fish_lsp"
    "jqls"
    "jsonls"
    "lua_ls"
    "marksman"
    "nil_ls"
    "prettier"
    "stylua"
  ];
  enabledLsps = with builtins;
    listToAttrs (
      map
      (lsp: {
        name = lsp;
        value = {
          enable = true;
          activate = lib.mkDefault (elem lsp defaultActivatedLsps);
        };
      })
      lspList
    );
in {
  lsp.servers = enabledLsps;
}

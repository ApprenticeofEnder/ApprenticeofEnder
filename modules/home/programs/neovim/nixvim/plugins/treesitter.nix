{pkgs, ...}:
# this automatically imports everything else in the parent folder
{
  plugins = {
    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      folding.enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        # keep-sorted start
        bash
        css
        dockerfile
        hcl
        html
        javascript
        json
        just
        lua
        make
        markdown
        nix
        python
        regex
        rust
        svelte
        terraform
        toml
        typescript
        xml
        yaml
        # keep-sorted end
      ];
      luaConfig = {
        pre = ''
          pcall(function()
            dofile(vim.g.base46_cache .. "syntax")
            dofile(vim.g.base46_cache .. "treesitter")
          end)
        '';
      };
    };
  };
}

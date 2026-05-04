{lib, ...}: {
  plugins.blink-cmp = {
    enable = true;
    lazyLoad = {
      settings = {
        event = ["BufRead"];
        enabled = lib.nixvim.mkRaw ''
          function()
            return not vim.g.vscode
          end
        '';
      };
    };

    luaConfig.post = ''
      require("lz.n").trigger_load("obsidian.nvim")
    '';
    settings = {
      signature = {
        enabled = true;
      };
      # ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      # ['<C-e>'] = { 'hide', 'fallback' },
      # ['<CR>'] = { 'accept', 'fallback' },
      #
      # ['<Tab>'] = { 'snippet_forward', 'fallback' },
      # ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      #
      # ['<Up>'] = { 'select_prev', 'fallback' },
      # ['<Down>'] = { 'select_next', 'fallback' },
      # ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
      # ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
      #
      # ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      # ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      #
      # ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      keymap = {
        preset = "enter";
      };
      completion = {
        documentation = {
          auto_show = true;
        };
      };
    };
  };
}

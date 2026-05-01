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

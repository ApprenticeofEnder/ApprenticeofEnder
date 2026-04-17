{lib, ...}: {
  plugins = {
    nvim-surround = {
      enable = true;
      lazyLoad = {
        settings.event = ["BufRead"];
      };
      settings = {
        aliases = lib.nixvim.mkRaw ''
          {
            ["b"] = "**",
            ["i"] = "_",
          }
        '';
      };
    };
  };
}

{lib, ...}: {
  plugins = {
    nvim-surround = {
      enable = true;
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

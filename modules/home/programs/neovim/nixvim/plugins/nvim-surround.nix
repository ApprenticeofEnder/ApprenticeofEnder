{...}: {
  plugins = {
    nvim-surround = {
      enable = true;
      settings = {
        aliases = ''
          {
            ["b"] = "**",
            ["i"] = "_",
          }
        '';
      };
    };
  };
}

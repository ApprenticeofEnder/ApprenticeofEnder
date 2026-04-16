{
  plugins.cloak = {
    enable = true;
    settings = {
      cloak_character = "*";
      enabled = true;
      highlight_group = "Comment";
      patterns = [
        {
          cloak_pattern = "=.+";
          file_pattern = [
            ".env*"
            "wrangler.toml"
            ".dev.vars"
          ];
        }
      ];
    };
  };
}

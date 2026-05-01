{
  plugins.cloak = {
    enable = true;
    lazyLoad = {
      settings.event = ["BufRead"];
    };
    settings = {
      cloak_character = "*";
      enabled = true;
      highlight_group = "Comment";
      patterns = [
        {
          cloak_pattern = "=.+";
          file_pattern = [
            # keep-sorted start
            ".act/secrets"
            ".dev.vars"
            ".env*"
            ".secrets"
            "wrangler.toml"
            # keep-sorted end
          ];
        }
      ];
    };
  };
}

{
  plugins = {
    smartcolumn = {
      enable = true;
      lazyLoad = {
        settings.event = ["BufRead"];
      };
      settings = {
        disabled_filetypes = [
          # keep-sorted start
          "dashboard"
          "help"
          "markdown"
          "text"
          # keep-sorted end
        ];
      };
    };
  };
}

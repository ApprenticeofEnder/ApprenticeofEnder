{...}: {
  plugins.eyeliner = {
    enable = true;
    settings = {
      highlight_on_key = true;
      dim = true;
      disabled_filetypes = [
        "help"
      ];
      disabled_buftypes = [
        "nofile"
      ];
    };
    lazyLoad = {
      settings.event = ["BufRead"];
    };
  };
}

{...}: {
  plugins = {
    # keep-sorted start block=yes
    barbar.enable = true;
    dashboard.enable = true;
    gitsigns = {
      enable = true;
      lazyLoad = {
        settings.event = ["BufRead"];
      };
    };
    web-devicons.enable = true;
    # keep-sorted end
  };
}

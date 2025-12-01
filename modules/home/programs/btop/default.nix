{
  programs.btop = {
    enable = true;
    themes = {
      nordic = builtins.readFile ./themes/nordic.theme;
    };
    settings = {
      color_theme = "nordic";
      vim_keys = true;
      shown_boxes = "mem net cpu proc gpu0";
      proc_sorting = "memory";
    };
  };
}

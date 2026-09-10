{...}: {
  home.shellAliases = {
    cat = "bat";
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };
}

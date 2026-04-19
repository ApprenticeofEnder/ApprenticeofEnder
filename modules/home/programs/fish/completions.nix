{...}: {
  xdg.configFile = {
    "fish/completions/just.fish".text = ''
      just --completions fish | source
    '';
  };
}

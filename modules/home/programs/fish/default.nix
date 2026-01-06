{...}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      mkdir = "mkdir -p";
    };
  };
}

{...}: {
  programs.tirith = {
    # TODO: Figure out if I really want this
    enable = false;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    allowlist = [
      "localhost"
    ];
  };
}

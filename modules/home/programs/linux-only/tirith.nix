{...}: {
  programs.tirith = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    allowlist = [
      "localhost"
    ];
  };
}

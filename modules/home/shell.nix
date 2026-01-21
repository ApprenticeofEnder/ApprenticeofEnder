{...}: {
  programs = {
    # on macOS, you probably don't need this
    bash = {
      enable = true;
      initExtra = ''
        # Custom bash profile goes here
      '';
    };

    # Type `z <pat>` to cd to some directory
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}

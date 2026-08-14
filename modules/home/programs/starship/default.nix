{
  # pkgs,
  ...
}: {
  # # Better shell prompt!
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # settings = lib.importTOML ./starship.toml;
  };
}

{
  # pkgs,
  lib,
  ...
}:
lib.mkMerge [
  # (lib.mkIf pkgs.stdenv.isLinux {
  #   })
  {
    # # Better shell prompt!
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = lib.importTOML ./starship.toml;
    };
  }
]

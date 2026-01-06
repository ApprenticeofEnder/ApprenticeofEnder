{
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      mkdir = "mkdir -p";
    };
    sessionVariables =
      {}
      // lib.mkIf pkgs.stdenv.isDarwin {
        LIBRARY_PATH = "${pkgs.libiconv}/lib";
      };
  };
}

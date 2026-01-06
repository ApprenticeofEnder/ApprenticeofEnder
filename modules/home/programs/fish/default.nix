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
    shellInit =
      ''
        fish_add_path ~/.local/bin
        source "$HOME/.config/op/plugins-nix.sh"
      ''
      // lib.mkIf pkgs.stdenv.isDarwin ''
        LIBRARY_PATH=${pkgs.libiconv}/lib
      '';
  };
}

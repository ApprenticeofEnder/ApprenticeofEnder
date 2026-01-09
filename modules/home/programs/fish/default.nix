{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isDarwin {
    programs.fish = {
      shellInit = ''
        set LIBRARY_PATH ${pkgs.libiconv}/lib
        fish_add_path "/opt/homebrew/bin/"
      '';
    };
  })
  {
    programs.fish = {
      enable = true;
      shellAliases = {
        mkdir = "mkdir -p";
      };
      shellInit = ''
        fish_add_path ~/.local/bin
        fish_add_path ~/.nix-profile/bin
        source "$HOME/.config/op/plugins-nix.sh"
      '';
    };
  }
]

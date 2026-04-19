{
  config,
  pkgs,
  lib,
  ...
}: let
  darwinShellInit = ''
    set LIBRARY_PATH ${pkgs.libiconv}/lib
    fish_add_path "/opt/homebrew/bin/"
  '';

  shellInit = ''
    fish_add_path ~/.local/bin
    # fish_add_path ~/.nix-profile/bin
    fish_add_path ${config.xdg.dataHome}/pnpm/global/bin
    source "$HOME/.config/op/plugins-nix.sh"

    set -x PNPM_HOME "${config.xdg.dataHome}/pnpm/global/bin"
  '';

  fullShellInit = lib.concatStrings (
    [shellInit]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      darwinShellInit
    ]
  );
in {
  programs.fish.shellInit = fullShellInit;
}

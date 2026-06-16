{
  config,
  pkgs,
  lib,
  ...
}: let
  additionalPaths = builtins.concatStringsSep "\n" (
    map (path: "fish_add_path ${path}") [
      "~/.local/bin"
      "${config.xdg.dataHome}/pnpm/global/bin"
      "~/.cargo/bin"
    ]
  );

  darwinShellInit = ''
    set LIBRARY_PATH ${pkgs.libiconv}/lib
    fish_add_path "/opt/homebrew/bin/"
  '';

  shellInit = ''
    ${additionalPaths}
    source "$HOME/.config/op/plugins-nix.sh"

    set -x PNPM_HOME "${config.xdg.dataHome}/pnpm/global"

    devenv hook fish | source
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

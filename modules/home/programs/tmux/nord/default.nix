{
  # keep-sorted start
  lib,
  pkgs-stable,
  # keep-sorted end
  ...
}: let
  nordPlugin = pkgs-stable.stdenv.mkDerivation {
    pname = "tmuxplugin-nord";
    version = "local";
    src = ./.;
    installPhase = ''
      target=$out/share/tmux-plugins/nord
      mkdir -p "$(dirname "$target")"
      cp -r . "$target"
    '';
    passthru.rtp = "${builtins.placeholder "out"}/share/tmux-plugins/nord";
  };
in {
  options.programs.tmux.nordPackage = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    description = "Local vendored nord tmux plugin";
  };
  config.programs.tmux.nordPackage = nordPlugin;
}

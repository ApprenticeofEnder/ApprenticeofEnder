{
  # keep-sorted start
  pkgs-stable,
  # keep-sorted end
  ...
}:
pkgs-stable.stdenv.mkDerivation {
  pname = "tmuxplugin-nord";
  version = "local";
  src = ./.;
  installPhase = ''
    target=$out/share/tmux-plugins/nord
    mkdir -p "$(dirname "$target")"
    cp -r . "$target"
  '';
  passthru.rtp = "${builtins.placeholder "out"}/share/tmux-plugins/nord/nord.tmux";
}

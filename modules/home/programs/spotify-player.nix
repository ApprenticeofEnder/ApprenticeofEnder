{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  {
    programs.spotify-player = {
      enable = true;
    };
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    programs.spotify-player = {
      package = pkgs.spotify-player.override {
        withAudioBackend = "pulseaudio";
      };
    };
  })
]

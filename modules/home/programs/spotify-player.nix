{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  {
    programs.spotify-player = {
      enable = lib.mkDefault true;
    };
  }
  (lib.mkIf pkgs.stdenv.isLinux {
    programs.spotify-player = {
      # TODO: Re-enable this once the compiler error is fixed
      enable = false;
      package = pkgs.spotify-player.override {
        withAudioBackend = "pulseaudio";
      };
    };
  })
]

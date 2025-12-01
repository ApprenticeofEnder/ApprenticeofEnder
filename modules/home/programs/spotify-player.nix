{ pkgs, ... }:
{
  programs.spotify-player = {
    enable = true;
    package = pkgs.spotify-player.override {
      withAudioBackend =
        if
          pkgs.stdenv.isLinux # This fixed an issue on EndeavourOS
        then
          "pulseaudio"
        else
          "";
    };
  };
}

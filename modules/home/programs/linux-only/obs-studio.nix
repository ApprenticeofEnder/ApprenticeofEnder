{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # keep-sorted start
      obs-backgroundremoval
      obs-gstreamer
      obs-pipewire-audio-capture
      obs-source-record
      obs-vkcapture
      # keep-sorted end
    ];
  };
}

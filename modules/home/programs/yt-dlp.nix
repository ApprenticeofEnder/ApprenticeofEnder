{pkgs, ...}: {
  home.packages = with pkgs; [
    yt-dlp
  ];

  xdg.configFile = {
    "yt-dlp.conf" = {
      text = ''
        -x

        -o ~/Music/Inbox/%(title)s.%(ext)s

        --audio-format mp3
      '';
    };
  };
}

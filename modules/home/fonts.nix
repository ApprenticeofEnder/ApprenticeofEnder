{pkgs, ...}: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Noto Color Emoji"];

      serif = ["Hack Nerd Font"];

      sansSerif = ["Hack Nerd Font"];

      monospace = ["Hack Nerd Font"];
    };
  };

  home.packages = with pkgs; [
    # keep-sorted start
    atkinson-hyperlegible-next
    fira-code
    fira-code-symbols
    fira-sans
    font-awesome
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    victor-mono
    # keep-sorted end
  ];
}

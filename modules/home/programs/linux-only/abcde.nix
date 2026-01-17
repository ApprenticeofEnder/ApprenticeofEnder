{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      abcde
    ];
  };

  programs.fish = {
    functions = {
      cdrip = ''
        abcde -o flac -B && notify-send "Rip Complete" "Your CD rip is finished!"
      '';
    };
  };
}

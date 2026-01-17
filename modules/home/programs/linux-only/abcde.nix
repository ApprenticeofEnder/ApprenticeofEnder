{pkgs, ...}: let
  readers = {
    robDay = {
      devFile = "cd-rday";
      idSerialShort = "RF6XA16";
    };
  };
in {
  home = {
    packages = with pkgs; [
      abcde
    ];
  };

  xdg = {
    configFile = {
      "udev/rules.d/cd.rules" = {
        text = ''
          ACTION=="add", KERNEL=="sr[0-9]", ENV{ID_SERIAL_SHORT}=="${readers.robDay.idSerialShort}", SYMLINK+="${readers.robDay.devFile}"
        '';
      };
    };
  };

  programs.fish = {
    functions = {
      cdrip = ''
        abcde -o flac -B -d /dev/${readers.robDay.devFile} && notify-send "Rip Complete" "Your CD rip is finished!"
      '';
    };
  };
}

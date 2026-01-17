{pkgs, ...}: let
  readers = {
    robDay = {
      devFile = "cd-rday";
      idSerialShort = "";
    };
  };
in {
  home = {
    packages = with pkgs; [
      abcde
    ];

    file = {
      "/etc/udev/rules.d/cd.rules" = {
        text = ''
          ACTION=="add", KERNEL=="sr[0-9]", ENV{ID_SERIAL_SHORT}=="${readers.robDay.idSerialShort}", SYMLINK+="${readers.robDay.devFile}"
        '';
      };
    };
  };

  # TODO: Maybe make a config file for udev rules?
  programs.fish = {
    functions = {
      cdrip = ''
        abcde -o flac -B -d /dev/${readers.robDay.devFile} && notify-send "Rip Complete" "Your CD rip is finished!"
      '';
    };
  };
}

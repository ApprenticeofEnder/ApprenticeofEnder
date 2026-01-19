{pkgs, ...}: let
  readers = {
    robDay = {
      devFile = "cd-rday";
      idSerialShort = "RF6XA16";
    };
  };
  ntfyTopic = "6N3gGuklnOsWbO4R-cdrip";
in {
  home = {
    packages = with pkgs; [
      abcde
    ];

    file = {
      ".abcde.conf" = {
        source = ./abcde.conf;
      };
    };
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
        abcde && ntfy publish ${ntfyTopic} "CD rip complete."
      '';
      ntfy-test = ''
        ntfy publish ${ntfyTopic} "NTFY TEST"
      '';
    };
  };
}

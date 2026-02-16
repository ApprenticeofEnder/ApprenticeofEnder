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
      cdparanoia
    ];

    file = {
      ".abcde.conf" = {
        text = ''
          ${builtins.readFile ./abcde.conf}
          CDPARANOIA=${pkgs.cdparanoia}/bin/cdparanoia
        '';
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
        set -x ntfyTopic ${ntfyTopic}

        ${builtins.readFile ./cdrip.fish}
      '';
      cdmigrate = builtins.readFile ./migrate.fish;
      cdmigrate-patch = builtins.readFile ./migrate-patch.fish;
      ntfy-test = ''
        ntfy publish ${ntfyTopic} "NTFY TEST"
      '';
    };
  };
}

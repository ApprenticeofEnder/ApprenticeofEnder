{
  programs.ssh = {
    enable = true;
    # includes = [];
    enableDefaultConfig = false;
    # extraOptionOverrides = {};

    matchBlocks = {
      # nixbuild = {
      #   checkHostIP = false;
      #   identitiesOnly = true;
      #   addKeysToAgent = "yes";
      #   host = "eu.nixbuild.net";
      #   serverAliveInterval = 60;
      #   hostname = "eu.nixbuild.net";
      #   identityFile = [ "~/.ssh/my-nixbuild-key" ];
      #   extraOptions = {
      #     PubkeyAcceptedKeyTypes = "ssh-ed25519";
      #     IPQoS = "throughput";
      #   };
      # };

      nixos-server = {
        port = 22;
        user = "ender";
        host = "nixos-server";
        checkHostIP = true;
        addKeysToAgent = "yes";
        hostname = "192.168.50.254";
        setEnv.TERM = "xterm-kitty";
      };

      nixos = {
        port = 22;
        host = "nixos";
        user = "ender";
        checkHostIP = true;
        addKeysToAgent = "yes";
        hostname = "192.168.64.6";
        setEnv.TERM = "xterm-kitty";
      };

      rpi5 = {
        port = 22;
        host = "rpi5";
        user = "ender";
        checkHostIP = true;
        addKeysToAgent = "yes";
        hostname = "192.168.50.241";
        setEnv = {
          TERM = "xterm-256color";
        };

        # addressFamily = null; # "any" | "inet" | "inet6"
        # certificateFile = [ ./.file ];

        # compression = false;
        # controlmaster = null; # "yes" | "no" | "ask" | "auto" | "autoask"
        # controlPath = null; # path to control socket used for connection sharing
        # controlPersist = "10am"; # whether control socket should remain open in background

        # identityFile = [];
        # identityAgent = [];
        # identitiesOnly = false;

        # hashKnownHosts = null;
        # userKnownHostsFile = "~/.ssh/known_hosts";

        # serverAliveInterval = 5;
        # serverAliveCountMax = 5;

        # proxyJump = "";
        # proxyCommand = "";

        #  match = ''
        #  host  canonical
        #  host  exec "ping -c1 -q 192.168.17.1"
        # '';

        # dynamicForwards  = [
        #   {
        #     "name" = {
        #       address = "localhost";
        #       port = 8080;
        #     };
        #   }
        # ];

        # remoteForwards = [
        #   {
        #     bind = {
        #       address = "10.0.0.13";
        #       port = 8080;
        #     };
        #     host = {
        #       address = "10.0.0.13";
        #       port = 80;
        #     };
        #   }
        # ];

        # localForwards = [
        #   {
        #     bind = {
        #       address = "10.0.0.13";
        #       port = "8080";
        #     };
        #     host = {
        #       address = "10.0.0.13";
        #       port = "80";
        #     };
        #   }
        # ];
      };
    };
  };
}

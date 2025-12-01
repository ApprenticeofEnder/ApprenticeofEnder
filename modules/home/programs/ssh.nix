{ pkgs, ... }:
let
  identityAgent =
    if pkgs.stdenv.isLinux then
      "~/.1password/agent.sock"
    else
      "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
in
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

      github = {
        port = 22;
        user = "git";
        host = "github.com";
        checkHostIP = true;
        identityFile = [ "~/.ssh/github.pub" ];
        identityAgent = [ identityAgent ];
        identitiesOnly = true;
      };

      rabbit-holes = {
        port = 22;
        user = "vpcadmin";
        host = "rabbit-holes.ctf";
        hostname = "10.0.2.51";
        checkHostIP = true;
        extraOptions = {
          strictHostKeyChecking = "no";
        };
        identityFile = [ "~/.ssh/cybersci_2025_regionals.pub" ];
        identityAgent = [ identityAgent ];
        identitiesOnly = true;
      };

      trc = {
        port = 22;
        user = "vpcadmin";
        host = "trc.ctf";
        hostname = "10.0.2.41";
        checkHostIP = true;
        extraOptions = {
          strictHostKeyChecking = "no";
        };
        identityFile = [ "~/.ssh/cybersci_2025_regionals.pub" ];
        identityAgent = [ identityAgent ];
        identitiesOnly = true;
      };

      defence = {
        port = 22;
        user = "vpcadmin";
        host = "inventory.ctf";
        hostname = "10.0.2.22";
        checkHostIP = true;
        identityFile = [ "~/.ssh/cybersci_2025_regionals.pub" ];
        identityAgent = [ identityAgent ];
        identitiesOnly = true;
      };

      homelab-pi = {
        port = 22;
        user = "ender";
        host = "homelab-pi";
        hostname = "192.168.18.100";
        checkHostIP = true;
        identityFile = [ "~/.ssh/pi_master.pub" ];
        identityAgent = [ identityAgent ];
        identitiesOnly = true;
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

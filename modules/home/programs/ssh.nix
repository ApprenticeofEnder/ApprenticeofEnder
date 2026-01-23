{pkgs, ...}: let
  identityAgent =
    if pkgs.stdenv.isLinux
    then "~/.1password/agent.sock"
    else "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";

  hostDefaults = {
    port = 22;
    checkHostIP = true;
    identityAgent = [identityAgent];
    identitiesOnly = true;
  };
in {
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

      github =
        hostDefaults
        // {
          user = "git";
          host = "github.com";
          identityFile = ["~/.ssh/github.pub"];
        };

      github-gist =
        hostDefaults
        // {
          user = "git";
          host = "gist.github.com";
          identityFile = ["~/.ssh/github.pub"];
        };

      homelab-pi =
        hostDefaults
        // {
          user = "ender";
          host = "homelab-pi";
          hostname = "192.168.18.100";
          identityFile = ["~/.ssh/pi_master.pub"];
        };

      poc-mongodb =
        hostDefaults
        // {
          user = "ec2-user";
          host = "poc-mongodb";
          hostname = "ec2-98-92-185-213.compute-1.amazonaws.com";
          identityFile = ["~/.ssh/robert_poc.pub"];
        };

      # rpi5 = {
      #   port = 22;
      #   host = "rpi5";
      #   user = "ender";
      #   checkHostIP = true;
      #   addKeysToAgent = "yes";
      #   hostname = "192.168.50.241";
      #   setEnv = {
      #     TERM = "xterm-256color";
      #   };
      #
      #   # addressFamily = null; # "any" | "inet" | "inet6"
      #   # certificateFile = [ ./.file ];
      #
      #   # compression = false;
      #   # controlmaster = null; # "yes" | "no" | "ask" | "auto" | "autoask"
      #   # controlPath = null; # path to control socket used for connection sharing
      #   # controlPersist = "10am"; # whether control socket should remain open in background
      #
      #   # identityFile = [];
      #   # identityAgent = [];
      #   # identitiesOnly = false;
      #
      #   # hashKnownHosts = null;
      #   # userKnownHostsFile = "~/.ssh/known_hosts";
      #
      #   # serverAliveInterval = 5;
      #   # serverAliveCountMax = 5;
      #
      #   # proxyJump = "";
      #   # proxyCommand = "";
      #
      #   #  match = ''
      #   #  host  canonical
      #   #  host  exec "ping -c1 -q 192.168.17.1"
      #   # '';
      #
      #   # dynamicForwards  = [
      #   #   {
      #   #     "name" = {
      #   #       address = "localhost";
      #   #       port = 8080;
      #   #     };
      #   #   }
      #   # ];
      #
      #   # remoteForwards = [
      #   #   {
      #   #     bind = {
      #   #       address = "10.0.0.13";
      #   #       port = 8080;
      #   #     };
      #   #     host = {
      #   #       address = "10.0.0.13";
      #   #       port = 80;
      #   #     };
      #   #   }
      #   # ];
      #
      #   # localForwards = [
      #   #   {
      #   #     bind = {
      #   #       address = "10.0.0.13";
      #   #       port = "8080";
      #   #     };
      #   #     host = {
      #   #       address = "10.0.0.13";
      #   #       port = "80";
      #   #     };
      #   #   }
      #   # ];
      # };
    };
  };
}

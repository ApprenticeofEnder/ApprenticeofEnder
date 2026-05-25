{
  pkgs,
  config,
  ...
}: let
  defaultIdentityAgent =
    if pkgs.stdenv.isLinux
    then "~/.1password/agent.sock"
    else "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";

  sshHost = {
    user ? config.me.username,
    port ? 22,
    hostname ? null,
    checkHostIP ? true,
    identityAgent ? defaultIdentityAgent,
    publicKeyName,
    identitiesOnly ? true,
    options ? {},
  }:
    {
      Port = port;
      User = user;
      HostName = hostname;
      CheckHostIP = checkHostIP;
      IdentityAgent = identityAgent;
      IdentitiesOnly = identitiesOnly;
      IdentityFile = sshKeyPath publicKeyName;
    }
    // options;

  sshKeyPath = name: "~/.ssh/${name}";

  sshKeyFile = name: publicKey: {
    name = sshKeyPath name;
    value = {
      text = publicKey;
    };
  };

  sshKeys = with builtins; let
    # ./keys contains only public keys
    keyNames = attrNames (readDir ./keys);
    readKey = keyName:
      sshKeyFile keyName (
        builtins.readFile ./keys/${keyName}
      );
  in
    builtins.listToAttrs (map readKey keyNames);
in {
  home.file = sshKeys;

  programs.ssh = {
    enable = true;
    # includes = [];
    enableDefaultConfig = false;
    # extraOptionOverrides = {};

    settings = {
      "github.com" = sshHost {
        user = "git";
        publicKeyName = "github.pub";
      };

      "gist.github.com" = sshHost {
        user = "git";
        publicKeyName = "github.pub";
      };

      "homelab-pi" = sshHost {
        hostname = "192.168.18.100";
        publicKeyName = "pi_master.pub";
      };

      "deployment-hell" = sshHost {
        user = "vpcadmin";
        hostname = "10.0.2.93";
        publicKeyName = "cybersci_2026_nationals.pub";
      };

      "assault-and-battery" = sshHost {
        user = "vpcadmin";
        hostname = "10.0.2.71";
        publicKeyName = "cybersci_2026_nationals.pub";
      };
    };

    # matchBlocks = {
    #   # nixbuild = {
    #   #   checkHostIP = false;
    #   #   identitiesOnly = true;
    #   #   addKeysToAgent = "yes";
    #   #   host = "eu.nixbuild.net";
    #   #   serverAliveInterval = 60;
    #   #   hostname = "eu.nixbuild.net";
    #   #   identityFile = [ "~/.ssh/my-nixbuild-key" ];
    #   #   extraOptions = {
    #   #     PubkeyAcceptedKeyTypes = "ssh-ed25519";
    #   #     IPQoS = "throughput";
    #   #   };
    #   # };
    #   # rpi5 = {
    #   #   port = 22;
    #   #   host = "rpi5";
    #   #   user = "ender";
    #   #   checkHostIP = true;
    #   #   addKeysToAgent = "yes";
    #   #   hostname = "192.168.50.241";
    #   #   setEnv = {
    #   #     TERM = "xterm-256color";
    #   #   };
    #   #
    #   #   # addressFamily = null; # "any" | "inet" | "inet6"
    #   #   # certificateFile = [ ./.file ];
    #   #
    #   #   # compression = false;
    #   #   # controlmaster = null; # "yes" | "no" | "ask" | "auto" | "autoask"
    #   #   # controlPath = null; # path to control socket used for connection sharing
    #   #   # controlPersist = "10am"; # whether control socket should remain open in background
    #   #
    #   #   # identityFile = [];
    #   #   # identityAgent = [];
    #   #   # identitiesOnly = false;
    #   #
    #   #   # hashKnownHosts = null;
    #   #   # userKnownHostsFile = "~/.ssh/known_hosts";
    #   #
    #   #   # serverAliveInterval = 5;
    #   #   # serverAliveCountMax = 5;
    #   #
    #   #   # proxyJump = "";
    #   #   # proxyCommand = "";
    #   #
    #   #   #  match = ''
    #   #   #  host  canonical
    #   #   #  host  exec "ping -c1 -q 192.168.17.1"
    #   #   # '';
    #   #
    #   #   # dynamicForwards  = [
    #   #   #   {
    #   #   #     "name" = {
    #   #   #       address = "localhost";
    #   #   #       port = 8080;
    #   #   #     };
    #   #   #   }
    #   #   # ];
    #   #
    #   #   # remoteForwards = [
    #   #   #   {
    #   #   #     bind = {
    #   #   #       address = "10.0.0.13";
    #   #   #       port = 8080;
    #   #   #     };
    #   #   #     host = {
    #   #   #       address = "10.0.0.13";
    #   #   #       port = 80;
    #   #   #     };
    #   #   #   }
    #   #   # ];
    #   #
    #   #   # localForwards = [
    #   #   #   {
    #   #   #     bind = {
    #   #   #       address = "10.0.0.13";
    #   #   #       port = "8080";
    #   #   #     };
    #   #   #     host = {
    #   #   #       address = "10.0.0.13";
    #   #   #       port = "80";
    #   #   #     };
    #   #   #   }
    #   #   # ];
    #   # };
    # };
  };
}

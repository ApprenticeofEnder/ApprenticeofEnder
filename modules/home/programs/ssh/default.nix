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

  cyberSciSshHost = {
    user ? "vpcadmin",
    hostname,
    checkHostIP ? true,
    publicKeyName,
  }:
    sshHost {
      inherit user;
      inherit hostname;
      inherit checkHostIP;
      inherit publicKeyName;

      options = {
        SetEnv = {
          TERM = "xterm-256color";
        };
        StrictHostKeyChecking = false;
      };
    };

  sshKeyPath = name: "~/.ssh/${name}";

  sshKeys = with builtins; let
    # ./keys contains only public keys
    keyNames = attrNames (readDir ./keys);
    readKey = keyName: {
      name = ".ssh/${keyName}";
      value = {
        text = readFile ./keys/${keyName};
      };
    };
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

      "deployment-hell" = cyberSciSshHost {
        hostname = "10.0.2.93";
        publicKeyName = "cybersci_2026_nationals.pub";
      };

      "assault-and-battery" = cyberSciSshHost {
        hostname = "10.0.2.71";
        publicKeyName = "cybersci_2026_nationals.pub";
      };

      "shellnet" = cyberSciSshHost {
        hostname = "10.0.2.141";
        publicKeyName = "cybersci_2026_nationals.pub";
      };

      "gitgoodgemma" = cyberSciSshHost {
        hostname = "10.0.2.21";
        publicKeyName = "cybersci_2026_nationals.pub";
      };

      defence = cyberSciSshHost {
        hostname = "10.0.2.90";
        publicKeyName = "cybersci_2026_nationals.pub";
      };
    };
  };
}

{
  lib,
  pkgs,
  ...
}: let
  vpn_root = "/home/ender/Documents/VPNs";

  cybersci = {
    events = {
      ntl = "n";
      rgnl = "r";
    };
  };

  trimYear = year: builtins.substring 2 4 year;

  mkVpn = name: {
    config_path,
    auto_start ? false,
  }:
    lib.nameValuePair name {
      config = ''config ${config_path}'';
      autoStart = auto_start;
    };

  mkCyberSciVpn = {
    event,
    year,
    teams ? [],
    dev_config,
  }: let
    event_prefix = builtins.concatStringsSep "" [
      cybersci.events."${event}"
      (trimYear year)
    ];
    prefix = "cybersci-${event_prefix}";
    dev_vpn = mkVpn "${prefix}-dev" {
      config_path = dev_config;
    };

    defence = map (team:
      mkVpn "${prefix}-${team}-defence" {
        config_path = builtins.concatStringsSep "/" [
          vpn_root
          event_prefix
          "defence-${team}"
          "cybersci-${event}-${team}.ovpn"
        ];
      })
    teams;
  in
    builtins.listToAttrs ([dev_vpn] ++ defence);

  vpnServers = lib.mergeAttrsList [
    (mkCyberSciVpn {
      event = "ntl";
      year = "2026";
      dev_config = "/home/ender/Projects/CyberSci/CS2026-NTL/infrastructure/cybersci-ntl-dev.ovpn";
      teams = [
        "club"
        "gogo"
        "malware"
        "maple"
        "offby"
        "pada"
        "sherbrooke"
        "status418"
        "t0ken"
      ];
    })
  ];

  vpnSwitchPkg = pkgs.writeShellScriptBin "vpn-switch" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    declare -a VPN_NAMES=(
      ${lib.concatStringsSep "\n      " (map (n: "\"${n}\"") (builtins.attrNames vpnServers))}
    )

    ${builtins.readFile ./vpn-switch.sh}
  '';
in {
  environment.systemPackages = [
    vpnSwitchPkg
  ];

  services.openvpn.servers = vpnServers;
}

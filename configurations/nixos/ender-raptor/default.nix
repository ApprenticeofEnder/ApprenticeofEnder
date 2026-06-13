# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{
  flake,
  lib,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (inputs) nixvim;
  inherit (inputs) stylix;
  homeMod = self + /modules/home;

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
        config_path = "${vpn_root}/${event_prefix}/cybersci-${event}-${team}.ovpn";
      })
    teams;
  in
    builtins.listToAttrs ([dev_vpn] ++ defence);
in {
  imports = [
    self.nixosModules.default
    self.nixosModules._1password
    stylix.nixosModules.stylix
    ./configuration.nix
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  home-manager.sharedModules = [
    nixvim.homeModules.default
    "${homeMod}/programs/linux-only"
  ];

  programs.nix-ld.enable = true;

  services.openvpn.servers = lib.mergeAttrsList [
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

  # Automatically move old dotfiles out of the way
  #
  # Note that home-manager is not very smart, if this backup file already exists it
  # will complain "Existing file .. would be clobbered by backing up". To mitigate this,
  # we try to use as unique a backup file extension as possible.
  home-manager.backupFileExtension = "nixos-unified-template-backup";

  # TODO: Stylix!

  myusers = ["ender"];
}

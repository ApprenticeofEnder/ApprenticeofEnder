{
  lib,
  pkgs,
  pkgs-stable,
  ...
}: let
  dev = with pkgs;
    [
      shfmt # shell formatter
      typst # latex alternative
      httpie # better http client
      gnumake
      vi-mongo # mongodb tui
      shellcheck # shell linter
      keep-sorted # line sorting
      mermaid-cli

      # nix-specific
      nil # lsp
      nix-info # system information
      nix-tree # dependency navigation
      alejandra # formatter

      omnix
      devenv
      cachix
    ]
    ++ [
      # pkgs-stable.devenv
      # pkgs-stable.cachix
    ];

  security = with pkgs; [
    nmap # recon
    snyk # vuln management
    gnutls
    tcpdump # network forensics
    wireshark # network forensics
    pulumi-esc # secrets management
    # _1password-gui # TODO: Work out the whole user/group requirement thing
    # _1password-cli
    semgrep
    zizmor
  ];

  devops = with pkgs; [
    act # local CI/CD testing
    pulumi # IaC
    ansible # deployment automation
    kubectl # k8s
    gama-tui # github actions manager
    opentofu # IaC
    terraform # IaC
    # terramaid
    actionlint # github actions linter
    ansible-lint # linter
  ];

  utility = with pkgs;
    [
      # System
      sd # better sed
      duf # disk usage
      pik # process info
      just # make for commands
      mosh # better SSH
      ncdu # disk usage (baobab-like tui)
      tldr # man with examples
      tree
      ttyd # terminal sharing
      procs # better ps
      unzip
      xclip
      lazyssh
      macchina
      libnotify
      cargo-seek

      # Research
      wiki-tui # wikipedia TUI

      # Routine
      lynx # text web browser
      md-tui # markdown reader
      ispell # spelling
    ]
    ++ [
      pkgs-stable.ntfy-sh # notifications when commands finish
    ];

  linux = with pkgs;
    [
      ksnip # screenshots
      termscp # scp tui, broken on darwin because of some samba library
      # TODO: Figure out how to get Docker working properly here
      kdePackages.okular
      lazyjournal
      systemctl-tui
      nvtopPackages.full

      less # needed for Ubuntu

      # fun that only works on Linux
      spotify
      hollywood

      # Research
      zotero # citation and document management
    ]
    ++ [
      pkgs-stable.krita
    ];

  x86Linux = with pkgs; [
    godot # game engine
    impala # wifi management
    audacity # audio editing
    handbrake # video file conversions
  ];

  darwin = with pkgs; [
    utm
    docker
    docker-compose
    podman

    # libraries
    libiconv
  ];

  fun = with pkgs; [
    genact
    smassh
    cmatrix
    asciiquarium
  ];
in {
  home.packages = with pkgs;
    dev
    ++ security
    ++ devops
    ++ utility
    ++ fun
    ++ lib.optionals stdenv.isLinux linux
    ++ lib.optionals (stdenv.isLinux && stdenv.isx86_64) x86Linux
    ++ lib.optionals stdenv.isDarwin darwin;
}
#
# TODO: Investigate the below tools
#
# hygg # TUI book reader
# pog
# uvx parllama
# uvx netshow
# uvx exosphere
# cargo-selector
# systemd-manager-tui
# tewi
# ssh-para
# terminaltexteffects
# nemu
# doxx
# hwinfo-tui
# fnug
# godap
# jwt-tui
# mcp-probe
# mcp-nixos
# bagels
# moneyterm
# ticker
# mqtttui
# taproom
# tuistash
# ballast
# calcure
# goto
# sshclick
# hostctl
# lssh
# neoss
# nap
# pinix
# chamber
# tick-rs


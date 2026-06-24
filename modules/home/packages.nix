{
  lib,
  pkgs,
  pkgs-stable,
  ...
}: let
  dev = with pkgs;
    [
      # keep-sorted start
      gnumake
      gopls
      httpie # better http client
      jujutsu
      keep-sorted # line sorting
      mermaid-cli
      shellcheck # shell linter
      shfmt # shell formatter
      typst # latex alternative
      vi-mongo # mongodb tui
      # keep-sorted end

      # nix-specific
      # keep-sorted start
      alejandra # formatter
      nil # lsp
      nix-info # system information
      nix-tree # dependency navigation
      # keep-sorted end

      # keep-sorted start
      cachix
      devenv
      omnix
      # keep-sorted end
    ]
    ++ [
      # pkgs-stable.devenv
      # pkgs-stable.cachix
    ];

  security = with pkgs; [
    # keep-sorted start
    gnutls
    nmap # recon
    pulumi-esc # secrets management
    ripsecrets
    # _1password-gui # TODO: Work out the whole user/group requirement thing
    # _1password-cli
    semgrep
    snyk # vuln management
    tcpdump # network forensics
    wireshark # network forensics
    zizmor
    # keep-sorted end
  ];

  devops = with pkgs; [
    # keep-sorted start
    act # local CI/CD testing
    actionlint # github actions linter
    ansible # deployment automation
    ansible-lint # linter
    gama-tui # github actions manager
    kubectl # k8s
    opentofu # IaC
    pulumi # IaC
    terraform # IaC
    # terramaid
    # keep-sorted end
  ];

  utility = with pkgs;
    [
      # System
      # keep-sorted start
      cargo-seek
      duf # disk usage
      exiftool
      imagemagick
      just # make for commands
      lazyssh
      libnotify
      macchina
      mosh # better SSH
      ncdu # disk usage (baobab-like tui)
      pik # process info
      procs # better ps
      sd # better sed
      tldr # man with examples
      tree
      ttyd # terminal sharing
      unzip
      xclip
      # keep-sorted end

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
      # keep-sorted start
      kdePackages.okular
      lazyjournal
      less # needed for Ubuntu
      nvtopPackages.full
      systemctl-tui
      termscp # scp tui, broken on darwin because of some samba library
      # keep-sorted end

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
    # keep-sorted start
    audacity # audio editing
    handbrake # video file conversions
    impala # wifi management
    slack
    tor-browser
    # keep-sorted end
  ];

  darwin = with pkgs; [
    # keep-sorted start
    docker
    docker-compose
    podman
    utm
    # keep-sorted end

    # libraries
    libiconv
  ];

  fun = with pkgs; [
    # keep-sorted start
    asciiquarium
    cmatrix
    genact
    smassh
    # keep-sorted end
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


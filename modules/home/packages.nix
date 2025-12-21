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
{
  lib,
  pkgs,
  ...
}: let
  dev = with pkgs; [
    fd # better find
    gh # Github CLI
    sd # better sed
    omnix
    procs # better ps
    shfmt # shell formatter
    typst # latex alternative
    cachix
    devenv
    gnumake
    vi-mongo # mongodb tui
    shellcheck # shell linter
    mermaid-cli

    # nix-specific
    nil # lsp
    nix-info # system information
    nix-tree # dependency navigation
    alejandra # formatter

    # rust, just in case
    cargo
    rustfmt
    rust-analyzer

    # js
    pnpm
    nodejs_24
  ];

  security = with pkgs; [
    nmap # recon
    gnutls
    semgrep # SAST
    tcpdump # network forensics
    wireshark # network forensics
    pulumi-esc # secrets management
    # _1password-gui # TODO: Work out the whole user/group requirement thing
    # _1password-cli
  ];

  devops = with pkgs; [
    act # local CI/CD testing
    pulumi # IaC
    ansible # deployment automation
    kubectl # k8s
    gama-tui # github actions manager
    opentofu # IaC
    ansible-lint # linter
  ];

  utility = with pkgs; [
    # System
    duf # disk usage
    pik # process info
    just # make for commands
    less # needed for Ubuntu
    mosh # better SSH
    ncdu # disk usage (baobab-like tui)
    tldr # man with examples
    tree
    ttyd # terminal sharing
    lazyssh
    termscp
    cargo-seek

    # Research
    zotero # citation and document management
    wiki-tui # wikipedia TUI
    presenterm # terminal based presentations

    # Routine
    lynx # text web browser
    md-tui # markdown reader
    ispell # spelling
  ];

  linux = with pkgs; [
    ksnip # screenshots
    krita # drawing
    lazyjournal
    systemctl-tui
    nvtopPackages.full

    # fun that only works on Linux
    spotify
    hollywood
  ];

  x86Linux = with pkgs; [
    impala # wifi management
    audacity # audio editing
    handbrake # video file conversions
    protonvpn-gui # VPN
  ];

  darwin = with pkgs; [
    utm
    docker
    podman

    # acre security
    dotnet-sdk
    dotnet-runtime

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

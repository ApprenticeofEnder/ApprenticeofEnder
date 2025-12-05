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
# arduino-cli-interactive # github.com/Vaishnav-Sabari-Girish/arduino-cli-interactive?ref=terminaltrove
# ballast
# calcure
# duf
# goto
# sshclick
# hostctl
# lssh
# neoss
# nap
# pinix
# lazy-etherscan
# chamber
# tick-rs

{ lib, pkgs, ... }:
let
  dev = with pkgs; [
    fd
    sd
    omnix
    typst
    cachix
    devenv
    direnv
    gnumake
    vi-mongo
    shellcheck
    mermaid-cli

    # nix-specific
    nil # lsp
    nix-info # system information
    nixpkgs-fmt # formatter

    # rust, just in case
    cargo
    rustfmt

    # js
    pnpm
    nodejs_24
  ];

  security = with pkgs; [
    nmap # recon
    gnutls
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
    just
    less # needed for Ubuntu
    tree
    ttyd
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
    lazyjournal
    systemctl-tui
  ];

  x86Linux = with pkgs; [
    impala # wifi management
    audacity # audio editing
    handbrake # video file conversions
  ];

  darwin = with pkgs; [
    utm

    # acre security
    dotnet-sdk
    dotnet-runtime
  ];

  fun = with pkgs; [
    genact
    smassh
    cmatrix
    asciiquarium
    hollywood
  ];
in
{
  home.packages = with pkgs;
    [
      (writeShellScriptBin "yls" (builtins.readFile ./scripts/yls.sh))
      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    ]
    ++ dev
    ++ security
    ++ devops
    ++ utility
    ++ fun
    ++ lib.optionals stdenv.isLinux linux
    ++ lib.optionals (stdenv.isLinux && stdenv.isx86_64) x86Linux
    ++ lib.optionals stdenv.isDarwin darwin;
}

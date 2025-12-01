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
    pnpm
    omnix
    cachix
    devenv
    direnv
    gnumake
    vi-mongo
    nodejs_24
    typst
    shellcheck
    mermaid-cli
    # nix-specific
    nil
    nix-info
    nixpkgs-fmt
  ];

  security = with pkgs; [
    nmap
    gnutls
    tcpdump
    pulumi-esc
    # wireshark # TODO: Figure out why THIS one fails
    # _1password-gui # TODO: Work out the whole user/group requirement thing
    # _1password-cli
  ];

  devops = with pkgs; [
    act
    pulumi
    ansible
    kubectl
    gama-tui
    opentofu
    ansible-lint
  ];

  utility = with pkgs; [
    pik # process info
    just
    less # needed for Ubuntu
    lynx
    tree
    ttyd
    md-tui
    zotero
    lazyssh
    termscp
    wiki-tui
    cargo-seek
    presenterm
  ];

  linux = with pkgs; [ lazyjournal systemctl-tui ];

  x86Linux = with pkgs;
    [
      impala # wifi management
    ];

  darwin = with pkgs; [
    utm

    # acre security
    dotnet-sdk
    dotnet-runtime
    # dotnet-runtime_10
  ];

  fun = with pkgs; [ genact smassh cmatrix asciiquarium ];
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
    ] ++ dev ++ security ++ devops ++ utility ++ fun
    ++ lib.optionals stdenv.isLinux linux
    ++ lib.optionals (stdenv.isLinux && stdenv.isx86_64) x86Linux
    ++ lib.optionals stdenv.isDarwin darwin;
}

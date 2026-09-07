{
  flake,
  config,
  pkgs,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;

  homeMod = "${self}/modules/home";

  importHome = folder: (filenames: map (filename: "${homeMod}/${folder}/${filename}") filenames);
in {
  imports =
    [
      inputs.nixvim.homeModules.default
      self.homeModules.default
      "${homeMod}/targets.nix"
    ]
    ++ importHome "programs" [
      "linux-only"
    ]
    ++ importHome "toolkits" [
      # keep-sorted start
      "game-dev.nix"
      "javascript.nix"
      "python.nix"
      "rust.nix"
      # keep-sorted end
    ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "ender";
    fullname = "Robert Babaev";
    email = "github@robertbabaev.tech";
  };

  op = {
    identity-agent = "~/.1password/agent.sock";
    ssh-sign = "/opt/1Password/op-ssh-sign";
    cli = "/usr/bin/op";
  };

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
  };

  services.espanso.package = pkgs.espanso-wayland;

  podman.enable = true;

  services.podman.containers = {
    "kind-hornet-control-plane" = {
      autoStart = true;
    };
  };

  toolkits.ai-server = {
    enable = true;

    # keep-sorted start block=yes
    acceleration = "cuda";
    bindHost = "0.0.0.0";
    models = [
      "deepseek-coder:1.3b"
      "qwen2.5-coder:3b"
    ];
    serverHost = "localhost";
    serverName = "ender-hornet";
    # keep-sorted end
  };

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    deadlock-mod-manager
  ];
}

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
    kind-hornet-control-plane = {
      autoStart = true;
      image = "docker.io/kindest/node@sha256:3489c7674813ba5d8b1a9977baea8a6e553784dab7b84759d1014dbd78f7ebd5";
      ports = [
        "40427:6443"
      ];
      volumes = [
        "a8214781454be5e6d80a4f135d4cfb0aade9689c57976db724c4a9ef99e0c018:/var:suid,exec,dev"
        "/lib/modules:/lib/modules:ro"
        "/dev/mapper:/dev/mapper"
      ];
      devices = [
        "/dev/fuse"
      ];
      labels = {
        "io.x-k8s.kind.role" = "control-plane";
        "io.x-k8s.kind.cluster" = "kind-hornet";
      };
      environment = {
        container = "podman";
        KUBECONFIG = "/etc/kubernetes/admin.conf";
      };
      network = "kind";
      extraPodmanArgs = [
        "--tmpfs"
        "/tmp"
        "--tmpfs"
        "/run"
      ];
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

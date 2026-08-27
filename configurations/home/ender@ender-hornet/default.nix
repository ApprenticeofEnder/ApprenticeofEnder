{flake, ...}: let
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
      "ai-server.nix"
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

  home.stateVersion = "25.05";
}

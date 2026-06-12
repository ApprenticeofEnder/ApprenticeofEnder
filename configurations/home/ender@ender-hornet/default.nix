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
      "ai-server.nix"
      "rust.nix"
      "python.nix"
      "javascript.nix"
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
    cli = "/opt/1Password/op";
  };

  home.stateVersion = "25.05";

  programs.fish.functions = {
    sudo = ''
      set -l -a banned_commands "nala install steam"
      set -l -a banned_commands "apt install steam"
      for command in $banned_commands;
          if test "$argv" != "$command"
              continue
          end
          echo "Command not allowed: sudo $command" >&2
          return 1
      end
      command sudo $argv
    '';
  };
}

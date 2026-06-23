{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;

  homeMod = "${self}/modules/home";

  importHome = folder: (filenames: map (filename: "${homeMod}/${folder}/${filename}") filenames);
in {
  imports =
    [
      self.homeModules.default
    ]
    ++ importHome "programs" [
      "darwin-only"
    ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "robertbabaev";
    fullname = "Robert Babaev";
    email = "github@robertbabaev.tech";
  };

  op = {
    identity-agent = "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
    ssh-sign = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    cli = "/opt/homebrew/bin/op";
  };

  home.stateVersion = "25.05";
}

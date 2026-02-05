{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.homeModules.default
    ../../modules/home/programs/linux-only
    ../../modules/home/toolkits/rust.nix
    ../../modules/home/toolkits/python.nix
    ../../modules/home/toolkits/javascript.nix
  ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "ender";
    fullname = "Robert Babaev";
    email = "github@robertbabaev.tech";
  };

  home.stateVersion = "25.05";
}

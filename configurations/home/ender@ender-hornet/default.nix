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

  home.stateVersion = "25.05";
}

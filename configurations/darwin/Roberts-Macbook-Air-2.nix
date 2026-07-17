# See /modules/darwin/* for actual settings
# This file is just *top-level* configuration.
{
  flake,
  config,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (inputs) nixvim;

  homeMod = "${self}/modules/home";

  importHome = folder: (filenames: map (filename: "${homeMod}/${folder}/${filename}") filenames);
in {
  imports = [
    self.darwinModules.default
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
  };

  networking.hostName = "Roberts-Macbook-Air-2";

  system.primaryUser = "robertbabaev";

  myusers = [config.system.primaryUser];

  ids.gids.nixbld = 350;

  # Automatically move old dotfiles out of the way
  #
  # Note that home-manager is not very smart, if this backup file already exists it
  # will complain "Existing file .. would be clobbered by backing up". To mitigate this,
  # we try to use as unique a backup file extension as possible.
  home-manager.backupFileExtension = "nixos-unified-template-backup";

  home-manager.sharedModules =
    [
      nixvim.homeModules.default
    ]
    ++ importHome "toolkits" [
      "rust.nix"
      "python.nix"
      "javascript.nix"
    ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}

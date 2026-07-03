# This is your nixos configuration.
# For home configuration, see /modules/home/*
{flake, ...}: {
  imports = [
    # keep-sorted start
    ./programs
    ./services
    flake.inputs.self.nixosModules.common
    # keep-sorted end
  ];
  services.openssh.enable = true;
}

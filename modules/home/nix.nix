{ config
, pkgs
, lib
, ...
}:
{
  # `nix.package` is already set if on `NixOS` or `nix-darwin`.
  # TODO: Avoid setting `nix.package` in two places. Does https://github.com/juspay/nixos-unified-template/issues/93 help here?
  nix.package = lib.mkDefault pkgs.lix;
  home.packages = [ config.nix.package ];
}

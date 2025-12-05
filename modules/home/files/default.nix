{ pkgs, ... }:
{
  home.file = {
    ".config/op/plugins-nix.sh" = {
      source = ./op.sh;
    };
  };
}

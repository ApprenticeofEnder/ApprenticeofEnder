{ pkgs, ... }:
{
  home.file = {
    ".local/bin/fit" = {
      source = ./fit.sh;
      executable = true;
    };
    ".config/op/plugins-nix.sh" = {
      source = ./op.sh;
    };
  };
}

# A module that automatically imports everything else in the parent folder.
# {
#   imports = with builtins;
#     map (fn: ./${fn}) (filter (
#       fn: fn != "default.nix" && fn != "ntfy.bak.nix" && fn != "ssh-agent.nix"
#     ) (attrNames (readDir ./.)));
# }
{
  flake,
  lib,
  ...
}: let
  inherit (flake) inputs;
  inherit (inputs) self;
  shared-lib = import (self + /modules/shared/lib) {
    inherit lib;
    globset = inputs.globset;
  };
in {
  imports = shared-lib.getNixImports {
    root = ./.;
    exclude = [
      "ntfy.bak.nix"
      "ssh-agent.nix"
    ];
  };
}

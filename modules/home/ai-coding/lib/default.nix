{lib, ...}: let
  agentHelpers = import ./agents.nix {inherit lib;};
  dataHelpers = import ./data.nix {inherit lib;};
  permissionHelpers = import ./permissions.nix {inherit lib;};
in
  agentHelpers // dataHelpers // permissionHelpers

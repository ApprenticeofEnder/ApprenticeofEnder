{lib, ...}: let
  ai_coding_lib = import ../../lib {
    inherit lib;
  };

  inherit (ai_coding_lib) mkAgent;

  description = ''
    Reviews overall project state and provides objective, direct feedback with constructive criticism and suggestions for improvement. Use at significant milestones, after major changes, or when reviewing a diff before it lands.
  '';

  name = "critic";
in
  mkAgent {
    inherit name;
    inherit description;
    claude_model = "opus";
    opencode_model = "opus";
    permission_groups = ["read" "bash" "plan"];
  }
